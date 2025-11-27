import { createRequire } from 'module';
import { getOctokitOptions } from "@actions/github/lib/utils.js";
import * as github from "@actions/github";
import * as core from "@actions/core";
import fs from "fs-extra";
import { getPackages } from "@manypkg/get-packages";
import path from "path";
import { getChangelogEntry } from "./utils.js";
import { throttling } from "@octokit/plugin-throttling";

const setupOctokit = (githubToken) => {
  const Octokit = github.getOctokit(githubToken, {
    throttle: {
      onRateLimit: (retryAfter, options, octokit, retryCount) => {
        core.warning(
          `Request quota exhausted for request ${options.method} ${options.url}`
        );

        if (retryCount <= 2) {
          core.info(`Retrying after ${retryAfter} seconds!`);
          return true;
        }
      },
      onSecondaryRateLimit: (
        retryAfter,
        options,
        octokit,
        retryCount
      ) => {
        core.warning(
          `SecondaryRateLimit detected for request ${options.method} ${options.url}`
        );

        if (retryCount <= 2) {
          core.info(`Retrying after ${retryAfter} seconds!`);
          return true;
        }
      },
    },
  }, throttling);
  
  return Octokit;
};

const getArtifactBaseName = (pkgName, version) => {
  const name = pkgName.replace("@", "").replace("/", "-");
  return `${name}-${version}`;
};

const uploadAsset = async (octokit, releaseId, assetPath, assetName) => {
    try {
        const content = await fs.readFile(assetPath);
        await octokit.rest.repos.uploadReleaseAsset({
            ...github.context.repo,
            release_id: releaseId,
            name: assetName,
            data: content,
        });
        core.info(`Uploaded ${assetName}`);
    } catch (e) {
        if (e.status === 422 && (e.message.includes("already_exists") || e.errors?.some(er => er.code === "already_exists"))) {
             core.info(`Asset ${assetName} already exists.`);
        } else {
            core.warning(`Failed to upload asset ${assetName}: ${e.message}`);
        }
    }
};

const createRelease = async (
  octokit,
  { pkg, tagName, artifactsPath }
) => {
  let release;
  try {
    let changelogFileName = path.join(pkg.dir, "CHANGELOG.md");

    let changelog = await fs.readFile(changelogFileName, "utf8");

    let changelogEntry = getChangelogEntry(changelog, pkg.packageJson.version);
    if (!changelogEntry) {
      // we can find a changelog but not the entry for this version
      // if this is true, something has probably gone wrong
      throw new Error(
        `Could not find changelog entry for ${pkg.packageJson.name}@${pkg.packageJson.version}`
      );
    }

    const response = await octokit.rest.repos.createRelease({
      name: tagName,
      tag_name: tagName,
      body: changelogEntry.content,
      prerelease: pkg.packageJson.version.includes("-"),
      ...github.context.repo,
    });
    release = response.data;
    core.info(`Created release for ${tagName}`);
  } catch (err) {
    if (err && err.status === 422 && err.message.includes("already_exists")) {
        core.info(`Release ${tagName} already exists.`);
        // Fetch the existing release to upload assets if needed
        try {
            const response = await octokit.rest.repos.getReleaseByTag({
                ...github.context.repo,
                tag: tagName
            });
            release = response.data;
        } catch (e) {
            core.warning(`Could not fetch existing release ${tagName}: ${e.message}`);
        }
    } else if (
      err &&
      typeof err === "object" &&
      "code" in err &&
      err.code !== "ENOENT"
    ) {
      throw err;
    }
  }
  
  // Upload artifacts if path provided and release exists
  if (artifactsPath && release) {
      const baseName = getArtifactBaseName(pkg.packageJson.name, pkg.packageJson.version);
      const extensions = ['.tgz', '.zip'];
      
      for (const ext of extensions) {
          const assetName = `${baseName}${ext}`;
          const assetPath = path.join(artifactsPath, assetName);
          
          if (await fs.pathExists(assetPath)) {
              core.info(`Found artifact: ${assetPath}`);
              await uploadAsset(octokit, release.id, assetPath, assetName);
          }
      }
  }
};

export async function syncReleases({
  githubToken,
  cwd = process.cwd(),
  artifactsPath,
}) {
  const octokit = setupOctokit(githubToken);
  
  let { packages, tool } = await getPackages(cwd);
  
  // Normalize artifacts path to be absolute if it's relative
  const absoluteArtifactsPath = artifactsPath ? path.resolve(cwd, artifactsPath) : undefined;
  
  if (tool === "root") {
     if (packages.length === 0) {
        core.warning("No packages found.");
        return;
     }
     let pkg = packages[0];
     let tagName = `v${pkg.packageJson.version}`;
     await createRelease(octokit, { pkg, tagName, artifactsPath: absoluteArtifactsPath });
  } else {
      for (let pkg of packages) {
          if (pkg.packageJson.private) continue; 
          
          let tagName = `${pkg.packageJson.name}@${pkg.packageJson.version}`;
          await createRelease(octokit, { pkg, tagName, artifactsPath: absoluteArtifactsPath });
      }
  }
}

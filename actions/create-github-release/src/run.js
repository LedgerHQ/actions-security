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

const createRelease = async (
  octokit,
  { pkg, tagName, targetBranch }
) => {
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

    await octokit.rest.repos.createRelease({
      name: tagName,
      tag_name: tagName,
      body: changelogEntry.content,
      prerelease: pkg.packageJson.version.includes("-"),
      target_commitish: targetBranch || undefined,
      ...github.context.repo,
    });
    core.info(`Created release for ${tagName}`);
  } catch (err) {
    if (err && err.status === 422 && err.message.includes("already_exists")) {
        core.info(`Release ${tagName} already exists.`);
    } else if (
      err &&
      typeof err === "object" &&
      "code" in err &&
      err.code !== "ENOENT"
    ) {
      throw err;
    }
  }
};

export async function syncReleases({
  githubToken,
  cwd = process.cwd(),
  targetBranch,
}) {
  const octokit = setupOctokit(githubToken);
  
  let { packages, tool } = await getPackages(cwd);
  
  if (tool === "root") {
     if (packages.length === 0) {
        core.warning("No packages found.");
        return;
     }
     let pkg = packages[0];
     let tagName = `v${pkg.packageJson.version}`;
     await createRelease(octokit, { pkg, tagName, targetBranch });
  } else {
      for (let pkg of packages) {
          if (pkg.packageJson.private) continue; 
          
          let tagName = `${pkg.packageJson.name}@${pkg.packageJson.version}`;
          await createRelease(octokit, { pkg, tagName, targetBranch });
      }
  }
}

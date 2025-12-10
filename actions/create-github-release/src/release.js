import * as core from "@actions/core";
import { syncReleases } from "./run.js";

(async () => {
  let githubToken = process.env.GITHUB_TOKEN || core.getInput("github_token");

  if (!githubToken) {
    core.setFailed("Please add the GITHUB_TOKEN to the changesets action");
    return;
  }

  const inputCwd = core.getInput("cwd");
  if (inputCwd) {
    core.info("changing directory to the one given as the input");
    process.chdir(inputCwd);
  }

  const targetBranch = core.getInput("target_branch");

  core.info("Syncing releases...");
  
  await syncReleases({
      githubToken,
      cwd: process.cwd(),
      targetBranch,
  });
  
  core.info("Release sync complete.");

})().catch((err) => {
  core.error(err);
  core.setFailed(err.message);
});

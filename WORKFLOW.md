For contributors unfamiliar with working on shared github repositories,
the _safe_ workflow is:

- Fork the repository (repo), clone _your fork_ to local machine
- Working on the repo? New branch for a new feature:
  - `git branch mynewbranchname`
  - `git checkout mynewbranchname`
  - Do work, commit work, then push work with `git push -u origin mynewbranchname`
- Head to github and send a pull request. It should even have noticed that you pushed a new branch and prompt you.
- When your PR is merged, update your master from the upstream
  - Make sure you have the upstream (the PRBEM/IRBEM version) added as a remote (see https://help.github.com/en/articles/configuring-a-remote-for-a-fork)
  - Make sure you are on _your_ master branch `git checkout master`
  - Update with `git pull --rebase upstream master`

Why not work from your master branch?
Well, depending on how pull requests and commits get merged with the upstream "main"
branch, e.g., merge commit, rebase, squash, ... and how you update (pull, pull with rebase)
you can end up with either extra commits or conflicting commits. The above workflow avoids
those issues and keeps updates organized, at the cost of a little bit of extra work.

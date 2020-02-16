![Continuous Integration](https://github.com/lucianposton/repoman-ebuild-qa-action/workflows/Continuous%20Integration/badge.svg)

# repoman-ebuild-qa-action

This action runs [repoman](https://wiki.gentoo.org/wiki/Repoman) in an
ebuild repository to find QA issues.

## Usage

Create a workflow file in your repository e.g. `.github/workflows/repoman.yml`.
An example workflow file is provided below. For more information, see
[Creating a workflow file](https://help.github.com/en/articles/configuring-a-workflow#creating-a-workflow-file).

### Example workflow

```yaml
name: 'Continuous Integration'
on: [push, pull_request]
jobs:
    repoman:
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v2
            - uses: lucianposton/repoman-ebuild-qa-action@v1
```

### Optional Inputs

* `repoman_args` -
            Additional arguments to pass after `repoman full`.
            Defaults to `-dx`. Note: This parameter will undergo shell
            wordsplitting and globbing.
* `path` -
            Path to cd to before starting repoman. The path is relative
            to the checked out repository. If unspecified or empty,
            repoman runs in the root of the repository.
* `portage_version` -
            The portage version to download containing repoman e.g.
            `2.3.80`. `latest` is the default value, which uses the latest
            released version.
* `profile` -
            The gentoo profile to set before running repoman. The default
            value is `latest`, which will result in using the first
            profile in `profiles.desc` listed under `SYMLINK_LIB=no`
            e.g. `default/linux/amd64/17.1`.
* `gentoo_repo` -
            Location to install the gentoo ebuild repository. This could
            be useful if using an old portage version that expects a
            different location. Default value is `/var/db/repos/gentoo`.

These optional inputs can be specified in the workflow file using the `with`
keyword [syntax](https://help.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idstepswith).

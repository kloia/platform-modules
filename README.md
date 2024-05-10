<img src="/assets/images/logos/kloia-logo-multicolor.svg" alt="Kloia Logo" title="Kloia" align="left" height="72" width="72"/>

# Kloia Platform Modules

This monorepo contains Terraform modules for building and managing infrastructure for platform development.

## Usage
Each module can be used by referencing its versioned git tag.
For example, to use the sample `metadata` module, you can include the
following snippet in your Terraform configuration

```hcl
module "metadata" {
  source = "git::https://github.com/kloia/platform-modules?ref=module/metadata/v0.1.0"
}
```

All module contents are released into their own separate tags with the convention of `module/<name>/<version>`.
No need to reference subdirectory of the repo with double-slashes `//`.

Modules can be found under the `modules/` directory.
Check out the GitHub Releases to find out the latest versions.

## Contributing

### Pre-commit

This project uses [pre-commit](https://pre-commit.com) to ensure the quality of the code.

Install the necessary dependencies, and setup pre-commit inside the repository.

```bash
brew install pre-commit tflint
pre-commit install
```

For more installation options visit the [pre-commits](https://pre-commit.com) and [terraform-hooks](https://github.com/antonbabenko/pre-commit-terraform#how-to-install).

### Commit Messages

The main branch's commits, and Pull Request titles must conform to [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

Commit messages need to be prefixed with the following.
- **feat:** A code change implements a new feature for the application.
- **fix:** A code change fixes a defect in the application.
- **refactor:** A code change that neither fixes a bug nor adds a feature
- **chore:** A code change includes a technical or preventative maintenance task that is necessary for managing the product or the repository, but it is not tied to any specific feature or user story. For example, regenerating generated code that must be included in the repository could be a chore.
- **ci:** A code change makes changes to continuous integration or continuous delivery scripts or configuration files.
- **docs:** Documentation only changes.
- **revert:** A code change reverts one or more commits that were previously included in the product, but were accidentally merged or serious issues were discovered that required their removal from the main branch.

### Branches, Releases, and Versioning

All modules must strictly follow SemVer 2.0

Pull Requests need to be merged onto main with **squash merges**.
This is done to keep a relatively clean linear history, which [release-please](https://github.com/googleapis/release-please)
reads commit messages from and creates new versioned releases and changelogs.

Once your pull request is merged to main, release-please will create a Pull Request,
proposing a change to update the version of the module.
When that release proposal Pull Request is approved and merged to main,
a GitHub Release and module specific tags will be created.

### License
This code is released under the MIT License.

### Contribution

You can fork the repository and contribute to the via pull-requests. Never hesitate and Community UP :smile: :heart:

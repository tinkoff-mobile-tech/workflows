# workflow

Repository with github reusable workflows. 

## Android library workflow

### Merge request 

Via `./gradlew check` , which included detekt, tests, lint.

#### Setup

1. Add to repository `.github/workflow/merge_request.yml`
```yml
name: merge request

on:
  pull_request:
    branches:
      - 'main'

jobs:
  check:
    uses: tinkoff-mobile-tech/workflows/.github/workflows/android_lib.merge_request.yml@v1
```

### Publish 

Publish aar to maven central via `./gradlew uploadArchive` (gradle task should be added in the project).

For release:
1. Go to "actions".
2. Select "Publish" on the left column with workflows.
3. Click on the green button "Run workflow".

! You should increment the version by yourself in the repository.

#### Setup

1. Add gradle plugin "maven" task `uploadArchive` [Example commit with a file.](https://github.com/tinkoff-mobile-tech/TinkoffID-Android/pull/12/commits/d24a2b3c2cd9f280f832e6c0ba10da061caf0864) or plugin "maven-publish" with task `publishReleasePublicationToMavenRepository`
2. Add to repository `.github/workflow/publish.yml`
```yml
name: publish

on:
  workflow_dispatch:


jobs:
  publish:
    uses: tinkoff-mobile-tech/workflows/.github/workflows/android_lib.publish.yml@v1
    secrets:
      gpg_key: ${{ secrets.GPG_KEY }}
      sign_ossrh_gradle_properties: ${{ secrets.SIGN_OSSRH_GRADLE_PROPERTIES }}
```

required secret environments:
- gpg_key - is base64 gpgkey. Example how to get it `base64 -i cert.der -o cert.base64`
- sign_ossrh_gradle_properties - file with gradle secret properties:
```properties
signing.keyId=
signing.password=
ossrhUsername=oss username
ossrhPassword=oss pass
```

### Use a specific java version

```yaml
jobs:
  check:
    uses: tinkoff-mobile-tech/workflows/.github/workflows/android_lib.merge_request.yml@v1
    with:
      java_version: '8'
```

by default java is 11

## iOS library workflow

### Setup 

1. `./Gemfile` in the root repository:

```
source "https://rubygems.org"

gem "cocoapods", "~> 1.11.3"
gem 'fastlane', '~> 2.204.3'
gem 'rubocop', '~> 0.93.1' # if exists
gem 'rubocop-require_tools'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
```

2. `fastlane/Pluginfile` 

```
gem 'fastlane-plugin-changelog'
```

3. `fastlane/Fastfile`

```ruby
import_from_git(
  url: "https://github.com/tinkoff-mobile-tech/workflows.git",
  branch: "master", 
  path: "fastlane/Fastfile" 
)
```

### setup merge request workflow

```yaml
name: merge request

on:
  pull_request:
    branches:
      - 'master'

jobs:
  check:
    uses: tinkoff-mobile-tech/workflows/.github/workflows/ios_lib.merge_request.yml@v1
    with:
      xcodeproj_path: "TinkoffID.xcodeproj"
      scheme_name: "TinkoffID-Package"
      podspec_name: "TinkoffID.podspec"
```

it calls `lint_fastfile`, `pod_lib_lint`, `swift package generate-xcodeproj`, `xcodebuild clean build`.

### setup publications

```yaml
name: publish

on:
  workflow_dispatch:
    inputs:
      bump_type:
        default: "patch"
        required: true
        type: string

jobs:
  publish:
    uses: tinkoff-mobile-tech/workflows/.github/workflows/ios_lib.publish.yml@v1
    with:
      xcodeproj_path: "TinkoffID.xcodeproj"
      scheme_name: "TinkoffID-Package"
      podspec_name: "TinkoffID.podspec"
      bump_type: ${{ inputs.bump_type }}
    secrets:
      cocapods_trunk_token: ${{ secrets.COCOAPODS_TRUNK_TOKEN }}
```

it pushes to cocapods trunk.

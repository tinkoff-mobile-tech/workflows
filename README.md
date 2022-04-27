# Reusable workflows

#### Setup your android / ios project workflow on GitHub in 5 minutes!

Reusable workflows for:
1. **Merge requests** **android / ios libs.**
2. **Publication** to **trunk** for ios libs.
3. **Publication** to **maven central** for android aar libs.

## Android library workflow

### Merge request 

Via `./gradlew check` , which included detekt, tests, lint.

#### Setup

Add to repository `.github/workflows/merge_request.yml`
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

#### Description 

0. Tag was pushed by developer.
1. The version from the source is picked up (by default from the gradle.propeties file at the root of the project).
2. Check if the same tag exists.
3. Published on maven Central https://mvnrepository.com/artifact/ru.tinkoff
4. A release will be created on github
5. The tag with the version number will push.

#### Usage

1. Go to "actions".
2. Select "Publish" on the left column with workflows.
3. Click on the green button "Run workflow".

! You should increment the version by yourself in the repository.

#### Setup

1. Add gradle plugin "maven" task `uploadArchive` [Example commit with a file.](https://github.com/tinkoff-mobile-tech/TinkoffID-Android/pull/12/commits/d24a2b3c2cd9f280f832e6c0ba10da061caf0864) or plugin "maven-publish" with task `publishReleasePublicationToMavenRepository`
2. Add to repository `.github/workflows/publish.yml`
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

### Setup for all workflows

1. `./Gemfile` in the root repository:

```
source "https://rubygems.org"

gem "cocoapods", "~> 1.11.3"
gem 'fastlane', '~> 2.204.3'
gem 'fastlane-plugin-changelog'
gem 'rubocop', '~> 0.93.1' # if exists
gem 'rubocop-require_tools'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
```

2`fastlane/Fastfile`

```ruby
import_from_git(
  url: "https://github.com/tinkoff-mobile-tech/workflows.git",
  path: "fastlane/Fastfile" 
)
```

### Merge request


#### Setup

Add to repository `.github/workflows/merge_request.yml`
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
```

use with `xcodeproj_path` and `scheme_name` only for spm built libs, for other options you don't have to.

it calls `lint_fastfile`, `pod_lib_lint`, `swift package generate-xcodeproj`, `xcodebuild clean build`.

### Publication

1. Runs lint and other checks.
2. The version is bumped in *.podspec files.
3. The changelog is being changed.
4. Pushed to cocaopods trunk repository.
5. The tag will push with the version number and modified *.podspec files.
6. The release card will be created in github.

#### Usage

1. Go to "actions".
2. Select "Publish" on the left column with workflows.
3. Click on the green button "Run workflow".
4. Type which type of version have to bump - patch / minor / major.

#### Setup

For publishing to work, secrets must be added to the project or organization: `COCOAPODS_TRUNK_TOKEN`
- How to get COCOAPODS_TRUNK_TOKEN - https://github.com/marketplace/actions/deploy-to-cocoapod-action
- How trunk publishing works - https://guides.cocoapods.org/making/making-a-cocoapod.html. 

Add to repository `.github/workflows/publish.yml`
```yaml
name: publish

on:
  workflow_dispatch:
    inputs:
      bump_type:
        required: true
        type: string

jobs:
  publish:
    uses: tinkoff-mobile-tech/workflows/.github/workflows/ios_lib.publish.yml@v1
    with:
      xcodeproj_path: "TinkoffID.xcodeproj"
      scheme_name: "TinkoffID-Package"
      bump_type: ${{ github.event.inputs.bump_type }}
    secrets:
      cocapods_trunk_token: ${{ secrets.COCOAPODS_TRUNK_TOKEN }}
```

#### How to change one more files during bump version.

Override lane `extend_bump_version`. Add to `fastlane/Fastfile`.
```ruby
override_lane :extend_bump_version do |options|
  version_swift="TinkoffASDKCore/TinkoffASDKCore/Version.swift"
  relative_file_path = "../" + version_swift
  data = File.read(relative_file_path)
  data = data.gsub(/versionString = \"([\d.]+)\"/, "versionString = \"#{options[:version]}\"")
  File.write(relative_file_path, data)
  [version_swift]
end
```
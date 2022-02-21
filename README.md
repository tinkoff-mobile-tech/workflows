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
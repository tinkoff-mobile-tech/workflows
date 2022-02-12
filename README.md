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
    uses: tinkoff-mobile-tech/workflow/.github/workflows/android_merge_request.yml@main
```

### Publish 

Publish aar to maven central via `./gradlew uploadArchive` (gradle task should be added in the project).

Release triggired by push tag as `\d+\.\d+\.\d+` for example: `1.0.3`

! You should increment the version by yourself in the repository.

#### Setup

1. Add gradle task uploadArchive. [Example commit with a file.](https://github.com/tinkoff-mobile-tech/TinkoffID-Android/pull/12/commits/d24a2b3c2cd9f280f832e6c0ba10da061caf0864)
2. Add to repository `.github/workflow/publish.yml`
```yml
name: publish

on:
  push:
    tags:
      - '\d+\.\d+\.\d+'


jobs:
  publish:
    uses: tinkoff-mobile-tech/workflow/.github/workflows/publish_android_aar.yml@main
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
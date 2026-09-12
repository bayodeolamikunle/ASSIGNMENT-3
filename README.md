# Assignment 3 — CI/CD with GitHub Actions

A Bash-based diagnostic CLI application with a local CI/CD pipeline using
GitHub Actions.

The pipeline validates the Bash scripts, runs automated tests, and builds
and smoke-tests a Docker image. There is no cloud deployment.

## Project Structure

```text
assignment-3/
├── README.md
├── app/
│   └── app.sh
├── scripts/
│   ├── lint.sh
│   └── build.sh
├── tests/
│   └── test.sh
├── .github/
│   └── workflows/
│       └── ci.yml
├── Dockerfile
├── compose.yaml
├── .dockerignore
└── grade.sh
```

## Requirements

The project is designed for a Linux environment.

Required tools:

- Bash
- Git
- Docker
- Docker Compose

Docker must be installed and running for the Docker build and smoke tests.

## Application

The diagnostic application is located at:

```bash
./app/app.sh
```

### Help

Display the application usage:

```bash
./app/app.sh help
```

### System Information

Display system information:

```bash
./app/app.sh system-info
```

The command displays runtime information including:

- Hostname
- Current user
- Date and time
- Operating system
- Kernel version
- System uptime

### Check Host

Resolve and check a hostname or IP address:

```bash
./app/app.sh check-host <host>
```

Example:

```bash
./app/app.sh check-host google.com
```

A successfully resolved host returns exit code `0`.

If the host cannot be resolved, the command returns exit code `1`.

### Check Port

Validate a port and check TCP connectivity:

```bash
./app/app.sh check-port <host> <port>
```

Example:

```bash
./app/app.sh check-port google.com 443
```

The port must be numeric and within the range `1–65535`.

### Exit Codes

The application uses the following exit codes:

| Exit Code | Meaning |
|-----------|---------|
| `0` | Successful operation |
| `1` | Valid operation failed, such as an unresolved host or unavailable port |
| `2` | Invalid command or invalid input |

Invalid input includes:

- Invalid command
- Missing host
- Missing port
- Non-numeric port
- Port below `1`
- Port above `65535`

## Linting

The linting script checks the repository structure and Bash syntax.

Run:

```bash
./scripts/lint.sh
```

The script:

1. Checks that all required files exist.
2. Runs `bash -n` against the Bash scripts.
3. Reports whether validation passed or failed.

ShellCheck may also be used as an additional check where available.

## Testing

The automated tests are located at:

```bash
./tests/test.sh
```

Run the test suite with:

```bash
./tests/test.sh
```

The test suite contains 10 meaningful tests covering:

1. Help command
2. System information
3. Invalid command
4. Missing host
5. Valid host
6. Missing port
7. Non-numeric port
8. Port below valid range
9. Port above valid range
10. Valid TCP port

A successful test run reports:

```text
Tests passed: 10
Tests failed: 0
All tests passed.
```

## Docker

Build the Docker image:

```bash
docker build -t devops-tool .
```

Run the help command:

```bash
docker run --rm devops-tool help
```

Run the system information command:

```bash
docker run --rm devops-tool system-info
```

The Docker image packages the Bash application and its required runtime
dependencies.

### Docker Build and Smoke Tests

The Docker build and smoke tests are handled by:

```bash
./scripts/build.sh
```

The script:

1. Builds the `devops-tool` Docker image.
2. Runs the `help` command.
3. Runs the `system-info` command.
4. Runs an invalid-command test.
5. Verifies that an invalid command returns exit code `2`.

A successful run reports:

```text
Docker build and smoke tests passed.
```

## Docker Compose

Validate the Compose configuration:

```bash
docker compose config
```

Run the help command using Compose:

```bash
docker compose run --rm devops-tool help
```

Run system information using Compose:

```bash
docker compose run --rm devops-tool system-info
```

## GitHub Actions CI/CD

The GitHub Actions workflow is located at:

```text
.github/workflows/ci.yml
```

The workflow runs automatically on:

- Push
- Pull request

The pipeline contains three jobs:

```text
Validate
   |
   v
Test
   |
   v
Docker Build and Smoke Test
```

### 1. Validate

The `validate` job runs the repository linting and Bash syntax checks:

```bash
./scripts/lint.sh
```

### 2. Test

The `test` job runs after the `validate` job succeeds.

It runs:

```bash
./tests/test.sh
```

The dependency is enforced with:

```yaml
needs: validate
```

### 3. Docker

The `docker` job runs after the `test` job succeeds.

It runs:

```bash
./scripts/build.sh
```

The dependency is enforced with:

```yaml
needs: test
```

Therefore, the pipeline follows this order:

```text
validate
    |
    v
test
    |
    v
docker
```

If an earlier job fails, later dependent jobs do not run.

## CI Failure Demonstration

A deliberate test failure was introduced on the
`feature/ci-failure-demo` branch to verify that the CI pipeline correctly
detects failing tests.

The invalid-command test was temporarily changed to expect exit code `0`
instead of the required exit code `2`.

The resulting GitHub Actions run showed:

```text
Validate: Passed
Test: Failed
Docker Build and Smoke Test: Skipped
```

The test was then corrected to expect exit code `2`.

After pushing the fix, GitHub Actions successfully completed:

```text
Validate: Passed
Test: Passed
Docker Build and Smoke Test: Passed
```

This demonstrated that the `needs:` dependencies correctly prevent later
pipeline stages from running when an earlier stage fails.

## Local CI Verification

The complete pipeline can be tested locally with:

```bash
./scripts/lint.sh
./tests/test.sh
./scripts/build.sh
```

All three commands must complete successfully before the project is
considered ready for submission.

## Grading

The supplied `grade.sh` script can be executed with:

```bash
chmod +x grade.sh app/*.sh scripts/*.sh tests/*.sh
./grade.sh
```

The grader checks items including:

- Repository structure
- Bash syntax
- Executable permissions
- GitHub Actions workflow
- Workflow triggers
- Job dependencies
- Application behaviour
- Linting
- Docker build and smoke tests
- Student tests
- Git history

Passing `grade.sh` does not necessarily guarantee a score of 100 because
code quality, Git practices, documentation, Docker configuration and other
requirements may also be reviewed manually.

## Assumptions

- The application is intended to run in a Linux environment.
- Docker must be installed and running for Docker-related tests.
- Network-dependent tests require network connectivity.
- Host resolution depends on the configured DNS/network environment.
- No cloud deployment is performed.
- No passwords, access tokens, private keys or other secrets are stored in
  the repository.
- Scripts do not depend on hardcoded machine-specific values.

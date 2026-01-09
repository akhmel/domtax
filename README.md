# Domtax

This application embeds a Rails Engine gem, `fund_load_restrictions`, which encapsulates the core business logic for processing fund load submissions, applying velocity rules, and persisting results.

## Embedded Gem: fund_load_restrictions

### What it does
- Accepts an uploaded input file where each line is a JSON object representing a fund load submission.
- Persists the file and splits it into chunks for background processing.
- Processes each line: parses JSON, looks up/creates the customer, and evaluates the submission against configurable velocity limit rules.
- Persists a `Submission` and per-rule `SubmissionVelocityLimitResult` records. Optional sanctions support is present via `SubmissionSanctionResult`.

### Architecture and flow
1) Upload and chunking
- Service `ProcessInputFile` persists the uploaded IO to `tmp/fund_loads/input_*.txt`, counts lines, computes chunk boundaries, and enqueues `ProcessInputChunkJob` for each chunk.
2) Chunk processing
- Job `ProcessInputChunkJob` reads only the assigned slice of lines, parses each JSON object, and invokes `ValidateSubmission`.
3) Submission validation
- Service `ValidateSubmission`:
  - Finds or creates a `Customer` by `ext_customer_id`.
  - Builds a `Submission` for each input.
  - Loads active velocity rules from `VelocityRuleRegistry` and evaluates them (rule classes live under `services/fund_load_restrictions/velocity_rules`).
  - Writes a `SubmissionVelocityLimitResult` per rule. Evaluation short-circuits on first decline.
4) Velocity rules registry
- Initializer `config/initializers/rules.rb` populates an in-memory registry (`VelocityRuleRegistry.current`) with active rules from the DB, safely no-oping before migrations exist.

### Data model (high level)
- `Customer` — external identifier mapping; owns many `Submission`s.
- `Submission` — one row per input line, with amount, currency, timestamp, and acceptance flag.
- `VelocityLimitRule` — DB-backed rule definitions with JSON config and active flag.
- `SubmissionVelocityLimitResult` — per submission per rule, acceptance and optional decline reason.
- `Sanction` and `SubmissionSanctionResult` — optional sanctions support (not evaluated in `ValidateSubmission` by default).

### Key files to review
- Engine and entry points:
  - `lib/fund_load_restrictions/lib/fund_load_restrictions.rb`
  - `lib/fund_load_restrictions/lib/fund_load_restrictions/engine.rb`
  - `lib/fund_load_restrictions/config/routes.rb`
- Initializers:
  - `lib/fund_load_restrictions/config/initializers/rules.rb` (velocity rule registry)
- Services:
  - `lib/fund_load_restrictions/app/services/fund_load_restrictions/process_input_file.rb`
  - `lib/fund_load_restrictions/app/jobs/fund_load_restrictions/process_input_chunk_job.rb`
  - `lib/fund_load_restrictions/app/services/fund_load_restrictions/validate_submission.rb`
  - Velocity rules:
    - `lib/fund_load_restrictions/app/services/fund_load_restrictions/velocity_rules/daily_fund_load_count_limit.rb`
    - `lib/fund_load_restrictions/app/services/fund_load_restrictions/velocity_rules/daily_fund_load_limit.rb`
    - `lib/fund_load_restrictions/app/services/fund_load_restrictions/velocity_rules/weekly_fund_load_limit.rb`
- Models:
  - `lib/fund_load_restrictions/app/models/fund_load_restrictions/customer.rb`
  - `lib/fund_load_restrictions/app/models/fund_load_restrictions/submission.rb`
  - `lib/fund_load_restrictions/app/models/fund_load_restrictions/velocity_limit_rule.rb`
  - `lib/fund_load_restrictions/app/models/fund_load_restrictions/submission_velocity_limit_result.rb`
  - `lib/fund_load_restrictions/app/models/fund_load_restrictions/sanction.rb`
  - `lib/fund_load_restrictions/app/models/fund_load_restrictions/submission_sanction_result.rb`
- Migrations:
  - `lib/fund_load_restrictions/db/migrate/*.rb` (tables for customers, submissions, results, sanctions, rules)
- Specs (examples of expected behavior and rule loading):
  - `spec/services/fund_load_restrictions/process_input_file_spec.rb`
  - `spec/services/fund_load_restrictions/validate_submission_spec.rb`
  - `spec/services/fund_load_restrictions/velocity_rules/*_spec.rb`

### How configuration works
- Velocity rules are stored in the database (`VelocityLimitRule`) with JSON `config` and `active` flag.
- At boot and on code reload, the initializer loads active rules into `VelocityRuleRegistry.current`.
- Rule class names are resolved dynamically from the `config` key (e.g., `{ "daily_fund_load_limit": { ... } }` resolves to `FundLoadRestrictions::VelocityRules::DailyFundLoadLimit`).

### Admin UI
- The app provides an ActiveAdmin page to upload `input.txt`/`input.json` and process it: `app/admin/fund_load_uploads.rb`.
- After processing, the page optionally displays the latest `output*.txt` (if generated) from `tmp/fund_loads/`.

### Deployment notes
- Heroku: `Procfile` runs Puma and applies migrations in the release phase.
- Production DB: all databases (primary/cache/queue/cable) share `DATABASE_URL`; each has separate migration paths.


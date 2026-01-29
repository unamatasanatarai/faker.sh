# Faker in Bash (Pure)

A lightweight, high-performance data generator written in 100% pure Bash. No forks, no subshells, no external dependencies (like perl, grep, or sed) for core operations.

## Features

- **Pure Bash**: Extremely fast, stays within a single process.
- **No Dependencies**: Works on any system with Bash 4.4+.
- **Localization**: Supports multiple locales (currently `en` and `pl`).
- **Extensible**: Easy to add new data types and locales.
- **Gender Specific**: Support for male/female names.

## Usage

Run the `fake` script with a task name:

```bash
./fake <task> [args] [options]
```

### Tasks

| Task | Description | Usage Examples | Example Output |
| :--- | :--- | :--- | :--- |
| `firstname` | First name | `./fake firstname`<br>`./fake firstname male`<br>`./fake firstname female` | `Olivia`<br>`Caleb`<br>`Autumn` |
| `lastname` | Last name | `./fake lastname`<br>`./fake lastname male`<br>`./fake lastname female` | `Marquardt`<br>`Goyette`<br>`Feil` |
| `person` | Full name | `./fake person`<br>`./fake person male`<br>`./fake person female` | `Retta Wolff`<br>`Lucas Beatty`<br>`Dylan McLaughlin` |
| `country` | Country name | `./fake country` | `Kazakhstan` |
| `country_abbr`| ISO Abbreviation | `./fake country_abbr`| `RW` |
| `city` | City name | `./fake city` | `Fairbanks` |
| `street_name` | Street name | `./fake street_name` | `Cabot Street` |
| `number` | Random number | `./fake number`<br>`./fake number 100 200` | `6961`<br>`192` |
| `postcode` | Postcode | `./fake postcode` | `99337` |
| `job_title` | Job title | `./fake job_title` | `Physiotherapy Assistant` |
| `email` | E-mail address | `./fake email` | `ronaldo.heller@icloud.com` |
| `phone_number` | Phone number | `./fake phone_number` | `+42 510 824 744` |
| `company` | Company name | `./fake company` | `Mueller Globe` |
| `url` | Company URL | `./fake url` | `https://www.moentransport.hotmail.com` |
| `uuid` | UUID v4 | `./fake uuid` | `3f6f121e-703c-40c0-881f-19f48e51d2a7` |
| `date` | Date (YYYY-MM-DD)| `./fake date`<br>`./fake date before`<br>`./fake date after` | `2022-02-15`<br>`2014-10-26`<br>`2026-02-19` |
| `time` | Time (HH:MM:SS) | `./fake time`<br>`./fake time after 14:00:00`<br>`./fake time before 10:00:00` | `20:28:26`<br>`19:31:57`<br>`06:46:22` |
| `lorem` | Lorem Ipsum | `./fake lorem`<br>`./fake lorem 5` | `quisquam`<br>`calcar tricesimus somnus venio talis` |

### Global Options

| Option | Description | Example Command | Example Output |
| :--- | :--- | :--- | :--- |
| `--locale` | Set data locale | `./fake person --locale pl` | `Waleria Kwaśniewski` |
| `--count` | Bulk generation | `./fake person --count 3` | `Cydney Ankunding`<br>`Bradley Moore`<br>`Laverne Klein` |
| `--seed` | Reproducibility | `./fake number --seed 123` | `2174` (Always the same) |

### Advanced Examples

Below are exhaustive examples showcasing the flexibility of `faker.sh` for every available command.

```bash
# -- PERSON --
# Generate a Polish female first name
$ ./fake firstname female --locale pl
# Generate a male last name
$ ./fake lastname male
# Generate 5 full names for a Polish context
$ ./fake person --locale pl --count 5
# Alias for person
$ ./fake name male

# -- LOCATION --
# Generate a random Polish city
$ ./fake city --locale pl
# Generate a street name
$ ./fake street_name
# Generate a 5-digit postcode
$ ./fake postcode
# Generate a random country and its abbreviation
$ ./fake country && ./fake country_abbr

# -- BUSINESS & MISC --
# Generate a job title in Polish
$ ./fake job_title --locale pl
# Generate a gender-specific email address
$ ./fake email female
# Generate a company name and its website URL
$ ./fake company && ./fake url
# Generate a random phone number
$ ./fake phone_number
# Generate a unique UUID v4
$ ./fake uuid

# -- NUMBERS & DRILL-DOWN --
# Random number between 1 and 100
$ ./fake number 1 100
# High-range random number
$ ./fake number 10000 99999

# -- DATE & TIME --
# Random date in the past (2010-2024)
$ ./fake date before
# Random date in the future (2026-2030)
$ ./fake date after
# Random time after 2 PM
$ ./fake time after 14:00:00
# Random time before 10 AM
$ ./fake time before 10:00:00
# Random time between 9 AM and 5 PM
$ ./fake time after 09:00:00 before 17:00:00

# -- LOREM --
# Generate a single lorem word
$ ./fake lorem
# Generate exactly 20 lorem words in a single line
$ ./fake lorem 20

# -- GLOBAL UTILITIES --
# Use a seed for reproducible datasets
$ ./fake person --seed 12345
# Generate bulk data with specific options
$ ./fake email male --count 10 --locale pl
```

## Performance & Architecture

- **Modularity**: Code is split into `lib/` providers (person, location, etc.) for maintainability.
- **Caching**: File contents are cached in memory during execution to speed up bulk generation.
- **Pure Bash**: No subshells, no forks, no external dependencies.
- **Randomness**: Uses cryptographically secure `SRANDOM` when available, or a high-entropy 30-bit `RANDOM` fallback.

## Installation

Simply clone the repository and ensure the `fake` script is executable:

```bash
git clone https://github.com/unamatasanatarai/faker.sh
cd faker.sh
chmod +x fake
```

## Internal Documentation

The script uses heredocs for internal function documentation. You can read the source of `fake` to understand how each function works. No subshells are used for internal function calls, relying on a shared `_RET` variable for maximum performance.

## License

MIT

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
./fake <task> [args] [--locale <lang>]
```

### Tasks

| Task | Description | Options |
| :--- | :--- | :--- |
| `person` | Full name | `male`, `female` |
| `firstname` | First name | `male`, `female` |
| `lastname` | Last name | `male`, `female` |
| `email` | E-mail address | `male`, `female` |
| `uuid` | UUID v4 | |
| `country` | Country name | |
| `country_abbr`| ISO Abbreviation | |
| `city` | City name | |
| `street_name` | Street name | |
| `number` | Street number | |
| `job_title` | Job title | |
| `company` | Company name | |
| `url` | Company URL | |
| `date` | Date (YYYY-MM-DD)| `before`, `after` |
| `time` | Time (HH:MM:SS) | |
| `lorem` | Lorem Ipsum | `[count]` |

### Examples

```bash
# Generate a random female person
./fake person female

# Generate a UUID
./fake uuid

# Generate a Polish name
./fake person --locale pl

# Generate 10 words of lorem ipsum
./fake lorem 10
```

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

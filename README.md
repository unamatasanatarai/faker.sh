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

| Task | Description | Example Command | Example Output |
| :--- | :--- | :--- | :--- |
| `person` | Full name | `./fake person` | `Bernie Schamberger` |
| `firstname` | First name | `./fake firstname` | `Kenya` |
| `lastname` | Last name | `./fake lastname` | `Bruen` |
| `email` | E-mail address | `./fake email` | `aglae.brown@outlook.com` |
| `uuid` | UUID v4 | `./fake uuid` | `2a876f72-52b7-495f-8c02-841e21582154` |
| `country` | Country name | `./fake country` | `Egypt` |
| `country_abbr`| ISO Abbreviation | `./fake country_abbr`| `VN` |
| `city` | City name | `./fake city` | `Kitchener` |
| `street_name` | Street name | `./fake street_name` | `Water Street` |
| `number` | Random number | `./fake number 1 100` | `85` |
| `postcode` | Postcode | `./fake postcode` | `61717` |
| `job_title` | Job title | `./fake job_title` | `Web Developer` |
| `company` | Company name | `./fake company` | `Davis Crest` |
| `url` | Company URL | `./fake url` | `https://www.rolfson.com` |
| `date` | Date (YYYY-MM-DD)| `./fake date after` | `2027-06-08` |
| `time` | Time (HH:MM:SS) | `./fake time` | `14:30:05` |
| `lorem` | Lorem Ipsum | `./fake lorem 3` | `odio et carbo` |

### Advanced Examples

```bash
# Generate a random male person
$ ./fake person male
Caleb Schroeder

# Generate a random female person
$ ./fake person female
Mia Kihn

# Change locale to Polish
$ ./fake person --locale pl
Antoni Nowak

# Specific number range
$ ./fake number 100 200
142

# Date before a certain range (randomly picks from history)
$ ./fake date before
2011-05-03
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

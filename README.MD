# speedrunning-dbt-snowflake

so this is basically me revising dbt + snowflake from scratch using the Berka dataset
(a real czech bank dataset from like the 90s, used in the PKDD'99 challenge). no
airflow, no glue, no s3, none of that — just raw csvs dumped into snowflake and then
dbt does literally everything else. keeping it small on purpose so i can rebuild this
whole thing from memory in like an hour if i ever need to.

## whats in the data

8 raw tables, all sitting in `raw.*` in snowflake:

| table    | rows (ish)  | what it is                                     |
|----------|-------------|--------------------------------------------------|
| account  | 4500        | bank accounts                                      |
| card     | 892         | credit cards, tied to a disposition                |
| client   | 5369        | the actual people                                  |
| disp     | 5369        | who can touch which account (owner / disponent)    |
| district | 77          | demographic/economic stuff per district            |
| loan     | 682         | loans                                              |
| orders   | 6471        | standing payment orders                            |
| trans    | ~1,056,320  | every single transaction, the big one              |

data's from here: https://www.kaggle.com/datasets/marceloventura/the-berka-dataset

## folder structure

```
models/
  staging/       one model per raw table, just cleaning stuff up 
  intermediate/  where actual joins happen + business logic that needs more than one table
  marts/         the "answer" tables, built for a specific question
macros/
  generate_schema_name.sql   stops dbt from prefixing every schema with raw_
```

each layer gets its own schema in snowflake (staging / intermediate / marts) so
raw data and transformed stuff dont get mixed up in the same place.

## what each layer actually does

**staging** — basically just cleanup. renaming cols, casting dates properly, and
decoding some czech strings into actual english (frequency codes, transaction type
codes etc). no joins allowed here, strictly one table in one table out.

**intermediate** — this is where it gets interesting. joins + interpretation.
- `int_account_owners` — joins disp + client + account, filtered to just OWNER type
  (only owners can actually take loans or set up standing orders, disponents cant)
- `int_loan_risk_flags` — turns the raw A/B/C/D loan status into is_defaulted /
  is_active flags so its actually usable
- `int_transaction_categorized` — mostly passthrough from staging but adds a flag
  for loan repayment transactions so you dont accidentally double count them later

**marts** — the actual deliverables
- `mart_loan_risk` — one row per loan. status, owner info, and a payment completion
  ratio (payments made vs expected) instead of just raw payment count, since newer
  loans obviously have fewer payments and that shouldnt look like a red flag
- `mart_account_activity` — account activity by month, credits/withdrawals/loan
  repayments, avg balance etc

## random data things i found along the way 

- `birth_number` is genuinely wild — its supposed to be YYMMDD but for women they
  just... add 50 to the month?? so month 62 = december (62-50) + tells you the
  client is female. one column two facts absolute nonsense encoding but kinda
  clever ngl
- also birth_number is NOT unique btw, multiple clients can have the exact same one
  since it only encodes dob + sex, not an actual id. only trust client_id
- loan payments show up TWICE in this dataset. once as a row in `loan` and again as
  individual transactions in `trans` (k_symbol = UVER). if you sum transaction
  amounts without filtering this out you will double count loan cashflow
- one district has a literal `'?'` string instead of real data for 1995
  (unemployment rate + crime count) bc it didnt exist as its own district yet that
  year. had to TRY_CAST instead of CAST
- found a `VYBER` value sitting in the `type` column when it should only ever be in
  `operation` — some rows are just inconsistent i guess, treated it as a withdrawal
  since thats what it means anyway
- loans that look "barely paid" (like only 1-2 payments) arent necessarily broken,
  sometimes they just started recently and havent had time to build up payment
  history yet. this is why the mart uses a ratio instead of a raw count

## how to actually run this

```bash
dbt debug             # do this
dbt run                 # do this too
dbt test                 # do this also
dbt docs generate         # graph good
dbt docs serve              # graph looks good
```

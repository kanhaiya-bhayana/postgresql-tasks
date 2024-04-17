CREATE SCHEMA IF NOT EXISTS cmd;

CREATE TABLE cmd.accounts (
    account_id text PRIMARY KEY,
    account_number varchar(20) UNIQUE NOT NULL,
    balance numeric
);

CREATE TABLE public.accounts (
    account_id text PRIMARY KEY,
    account_number varchar(20) UNIQUE NOT NULL,
    balance numeric
);

DROP TABLE cmd.accounts;
TRUNCATE TABLE public.accounts;

INSERT INTO cmd.accounts (account_id, account_number, balance)
VALUES (1,'A43341', 1000.50), (2,'A43241', 1000.50), (3,'B43341', 1000.50), (4,'A43451', 1000.50);

SELECT * FROM cmd.accounts;
SELECT * FROM public.accounts;

UPDATE cmd.accounts SET account_number = 'AAAA1', balance = 11110.50 WHERE account_id = '1';


CREATE OR REPLACE FUNCTION cmd.insert_or_update_accounts()
RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Handle INSERT logic here
-- 		RAISE NOTICE 'NEW values: account_id=%, account_number=%, balance=%', NEW.account_id, NEW.account_number, NEW.balance;
        INSERT INTO public.accounts (account_id, account_number, balance)
        SELECT account_id, account_number, balance FROM cmd.accounts;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Handle UPDATE logic here
        UPDATE public.accounts
        SET
            account_number = cmda.account_number,
            balance = cmda.balance
			FROM cmd.accounts AS cmda
        WHERE public.accounts.account_id = cmda.account_id; -- Compare with OLD values
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS if_dist_exists ON films;


DROP TRIGGER IF EXISTS after_update_accounts_statement on cmd.accounts;

CREATE TRIGGER after_insert_accounts_statement
AFTER INSERT ON cmd.accounts
FOR EACH STATEMENT
EXECUTE FUNCTION cmd.insert_or_update_accounts();

CREATE TRIGGER after_update_accounts_statement
AFTER UPDATE ON cmd.accounts
FOR EACH STATEMENT
EXECUTE FUNCTION cmd.insert_or_update_accounts();





-- Insert Customers
INSERT INTO bank_customers (first_name, last_name, email, phone) 
VALUES ('Alice', 'Uwase', 'alice.uwamahoro@email.com', '+250781112233');

INSERT INTO bank_customers (first_name, last_name, email, phone) 
VALUES ('Frank', 'Habimana', 'eric.habimana@email.com', '+250782223344');

INSERT INTO bank_customers (first_name, last_name, email, phone) 
VALUES ('Diane', 'Mutesi', 'diane.mutesi@email.com', '+250783334455');

-- Insert Accounts
INSERT INTO bank_accounts (customer_id, account_type, balance, status) 
VALUES (1, 'SAVINGS', 150000.00, 'ACTIVE');

INSERT INTO bank_accounts (customer_id, account_type, balance, status) 
VALUES (1, 'CHECKING', 45000.50, 'ACTIVE');

INSERT INTO bank_accounts (customer_id, account_type, balance, status) 
VALUES (2, 'SAVINGS', 320000.00, 'ACTIVE');

INSERT INTO bank_accounts (customer_id, account_type, balance, status) 
VALUES (3, 'CHECKING', 12000.00, 'ACTIVE');

COMMIT;

SET SERVEROUTPUT ON;

-- 1. Test get_account_balance function
DECLARE
    v_bal NUMBER;
BEGIN
    v_bal := get_account_balance(1);
    DBMS_OUTPUT.PUT_LINE('Account 1 Balance: ' || v_bal);
END;
/

-- 2. Test process_transaction procedure (Deposit)
BEGIN
    process_transaction(p_account_id => 1, p_type => 'DEPOSIT', p_amount => 25000.00);
END;
/

-- 3. Test apply_monthly_interest procedure (Bulk Processing & Collections)
BEGIN
    apply_monthly_interest(0.03);
END;
/

-- 4. Test get_customer_total_balance function
DECLARE
    v_total NUMBER;
BEGIN
    v_total := get_customer_total_balance(1);
    DBMS_OUTPUT.PUT_LINE('Customer 1 Total Balance: ' || v_total);
END;
/

CREATE OR REPLACE FUNCTION get_account_balance (
    p_account_id IN bank_accounts.account_id%TYPE
) RETURN NUMBER IS
    v_balance bank_accounts.balance%TYPE;
BEGIN
    SELECT balance 
    INTO v_balance
    FROM bank_accounts
    WHERE account_id = p_account_id;

    RETURN v_balance;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: Account ID ' || p_account_id || ' does not exist.');
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error: Multiple accounts found for this ID.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20099, 'Unexpected error: ' || SQLERRM);
END get_account_balance;
/

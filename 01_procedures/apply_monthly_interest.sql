CREATE OR REPLACE PROCEDURE apply_monthly_interest (
    p_interest_rate IN NUMBER DEFAULT 0.02 -- 2% interest
) IS
    -- Custom record definition for accounts
    TYPE t_account_rec IS RECORD (
        account_id bank_accounts.account_id%TYPE,
        balance    bank_accounts.balance%TYPE
    );

    -- Nested table collection of records
    TYPE t_account_list IS TABLE OF t_account_rec;
    v_accounts t_account_list;

    -- Explicit cursor
    CURSOR c_savings_accounts IS
        SELECT account_id, balance
        FROM bank_accounts
        WHERE account_type = 'SAVINGS' AND status = 'ACTIVE';

    bulk_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(bulk_errors, -24381);
BEGIN
    -- Bulk collect into collection
    OPEN c_savings_accounts;
    FETCH c_savings_accounts BULK COLLECT INTO v_accounts;
    CLOSE c_savings_accounts;

    IF v_accounts.COUNT > 0 THEN
        -- Bulk processing using FORALL and SAVE EXCEPTIONS
        FORALL i IN 1..v_accounts.COUNT SAVE EXCEPTIONS
            UPDATE bank_accounts
            SET balance = balance + (v_accounts(i).balance * p_interest_rate)
            WHERE account_id = v_accounts(i).account_id;

        DBMS_OUTPUT.PUT_LINE('Interest successfully applied to ' || v_accounts.COUNT || ' savings accounts.');
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No active savings accounts found.');
    END IF;

EXCEPTION
    WHEN bulk_errors THEN
        DBMS_OUTPUT.PUT_LINE('Errors occurred during bulk processing:');
        FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('Error at index ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX ||
                                 ' : ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
        END LOOP;
        COMMIT;
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error applying interest: ' || SQLERRM);
END apply_monthly_interest;
/

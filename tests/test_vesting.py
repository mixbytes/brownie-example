import brownie


def test_vesting_grant_add(accounts, token, Vesting, chain):
    owner = accounts[0]
    owner_balance = token.balanceOf(owner)
    vesting = Vesting.deploy(token, {'from': owner})

    recipient = accounts[1]
    duratation = 30
    amount = 100
    token.approve(vesting, 10**6, {'from': owner})
    vesting.addGrant(recipient, chain.time(), amount, duratation, {'from': owner})

    grants = vesting.getActiveGrants(recipient)
    assert len(grants) == 1
    grant = vesting.tokenGrants(grants[0])
    assert grant[5] == recipient
    assert grant[2] == duratation
    assert grant[1] == amount



def test_vesting_grant_claim_full(accounts, token, Vesting, chain):
    owner = accounts[0]
    owner_balance = token.balanceOf(owner)
    vesting = Vesting.deploy(token, {'from': owner})

    recipient = accounts[1]
    duratation = 30
    amount = 100
    token.approve(vesting, 10**6, {'from': owner})
    vesting.addGrant(recipient, chain.time(), amount, duratation, {'from': owner})

    chain.sleep(86400 * 30)

    vesting.claim(0, { 'from': recipient })
    assert token.balanceOf(recipient) == amount
    


def test_vesting_grant_claim_part(accounts, token, Vesting, chain):
    owner = accounts[0]
    owner_balance = token.balanceOf(owner)
    vesting = Vesting.deploy(token, {'from': owner})

    recipient = accounts[1]
    duratation = 30
    amount = 100
    startTime = chain.time()
    token.approve(vesting, 10**6, {'from': owner})
    vesting.addGrant(recipient, startTime, amount, duratation, {'from': owner})

    chain.sleep(86400 * duratation // 2)

    vesting.claim(0, { 'from': recipient })
    assert token.balanceOf(recipient) == amount // 2


def test_vesting_grant_remove(accounts, token, Vesting, chain):
    owner = accounts[0]
    owner_balance = token.balanceOf(owner)
    vesting = Vesting.deploy(token, {'from': owner})

    recipient = accounts[1]
    duratation = 30
    amount = 100
    startTime = chain.time()
    token.approve(vesting, 10**6, {'from': owner})
    vesting.addGrant(recipient, startTime, amount, duratation, {'from': owner})

    chain.sleep(86400 * duratation // 2)

    vesting.removeGrant(0, { 'from': owner })
    assert token.balanceOf(recipient) == amount // 2
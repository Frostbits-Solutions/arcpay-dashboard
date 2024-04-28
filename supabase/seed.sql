insert into subscription_tiers (id, name, listing_flat_fee, sale_percentage_fee, allow_secondary_sales, allow_premium_contracts) values (0, 'free', 100, 2, false, false);
insert into accounts (id, name, owner_email) values (0, 'Test', 'corentin@frostbits.solutions');
insert into accounts_users_association (role, account_id, user_email) values ('admin', 0, 'wilder@frostbits.solutions');
insert into accounts_api_keys (origin, name, account_id) values ('http://localhost:5173', 'Dev Key', 0);
insert into accounts_addresses (address, name, account_id, chain) values ('UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY', 'Test Wallet', 0, 'voi:testnet');
insert into currencies (id, name, ticker, chain) values (0, 'voi', 'voi', 'voi:testnet');
insert into listings
    (id, account_id, status, seller_address, listing_currency, listing_type, app_id, asset_id, listing_name, asset_thumbnail, asset_type, asset_qty, asset_creator, tags, chain)
values
    ('9de87750-df76-44af-a8f1-aa39157fdb0c', 0, 'closed', 'VOIUK3B5KQXVMVMYMLZOELHNABRKV27BP3CZRIK2ZCF7HEFP4F6APX76NM', 0, 'sale', 29084618, '29084618/10', 'VOIVIP10', 'https://prod.cdn.highforge.io/t/29084618/10.webp', 'ARC72', 1, 'BSVFQL2I7YZWVRQ5THOPTXZXPUYOMYPXUGJUQLVZGQEEPJ27EUZCPEANDI', 'primary/voivip', 'voi:testnet'),
    ('d1921524-7e6f-459a-a719-e6e6ee4056ae', 0, 'active', 'VOIUK3B5KQXVMVMYMLZOELHNABRKV27BP3CZRIK2ZCF7HEFP4F6APX76NM', 0, 'auction', 29088600, '29088600/7', 'Empty Cassette Case #7', 'https://prod.cdn.highforge.io/t/29088600/7.webp', 'ARC72', 1, 'BVWZNHUTAXJL754GL3RTCSDMOO6LYV4JMUO3M7MGBJ6VPAMBY7DRYOGLSQ', 'primary/cassette', 'voi:testnet');
insert into sales (listing_id, asking_price) values ('9de87750-df76-44af-a8f1-aa39157fdb0c', 1000);
insert into auctions (listing_id, start_price, min_increment, duration, type) values ('d1921524-7e6f-459a-a719-e6e6ee4056ae', 1000, 500, 10512000, 'english');
insert into transactions
    (id, from_address, app_id, type, amount, currency, note, chain)
values
    ('Z7RDJ3GTDR5M2VVSB6HGJOOZS7FQQMC3O3SYUGQP7RE6ESE24YLA', 'UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY', 29084618, 'buy', 1000, 0, '', 'voi:testnet'),
    ('SJHWRBS63AKMXJAM4QHEWXQ2A4XT637CN5BLF24FW5XG3QDYBAEA', 'UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY', 29088600, 'bid', 1000, 0, '', 'voi:testnet'),
    ('IJFGN4H5UBQGBLGWIEP4GAAZGCDTOZTNLFE7WCJ74KCXWMBVXPYA', 'UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY', 29088600, 'bid', 1500, 0, '', 'voi:testnet');

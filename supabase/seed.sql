-- Partition transactions table
DO $$
DECLARE partition_name text='transactions_' || to_char(CURRENT_DATE, 'YYYY_MM_DD');
BEGIN
    EXECUTE 'CREATE TABLE ' || partition_name || ' PARTITION OF public.transactions
        FOR VALUES FROM (CURRENT_DATE) TO (CURRENT_DATE + INTERVAL ''1 day'')';
    EXECUTE format('ALTER TABLE "public"."%I" ENABLE ROW LEVEL SECURITY', partition_name);
    EXECUTE format('GRANT SELECT ON TABLE "public"."%I" TO "anon"', partition_name);
    EXECUTE format('GRANT SELECT ON TABLE "public"."%I" TO "authenticated"', partition_name);
    EXECUTE format('GRANT ALL ON TABLE "public"."%I" TO "service_role"', partition_name);
    EXECUTE format('CREATE POLICY "Enable read access for all users" ON "public"."%I" FOR SELECT USING (true)', partition_name);
END $$;
SELECT cron.schedule('create_daily_transactions_partition', '0 0 * * *', 'SELECT "private"."create_daily_transactions_partition"();');

-- Seed data
INSERT INTO "public"."networks" ("id", "chain", "netid", "node_url", "node_port", "node_token") VALUES
('voi:testnet', 'voi', 'testnet', 'https://voitest-api.algorpc.pro/', 443, null),
('voi:mainnet', 'voi', 'voimain', 'https://mainnet-api.voi.nodely.dev/', 443, null),
('algo:testnet', 'algo', 'testnet', 'https://testnet-api.algonode.cloud', 443, null),
('algo:mainnet', 'algo', 'mainnet', 'https://mainnet-api.algonode.cloud', 443, null);
INSERT INTO "public"."subscription_tiers" ("name", "allow_secondary_listings", "allow_custom_currencies", "duration") VALUES ('free', false, false, null);
INSERT INTO "public"."subscriptions_networks_parameters" ("subscription_id", "network_id", "flat_fees", "sales_fees", "secondary_flat_fees", "secondary_sales_fees") VALUES
(1, 'voi:testnet', 1000, 0.2, 1000, 0.2),
(1, 'voi:mainnet', 1000, 0.2, 1000, 0.2),
(1, 'algo:testnet', 10, 0.2, 20, 0.2),
(1, 'algo:mainnet', 10, 0.2, 20, 0.2);
INSERT INTO "public"."currencies" ("id", "network_id", "name", "ticker", "icon", "type", "decimals", "is_public") VALUES
('0', 'voi:testnet', 'voi', 'voi', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAACl0lEQVQ4jY2VwUtUURTGf/fOzBtncsTIQCfFIlPHiIpsIbTQFoU7BZVauIhaWrpK8g8IykUulCA3FrRxsLSIqISSCoKKQBEqJiLLdKWmzTjz3sy7Ld5zeDO+CT+4vMt3zvnOvYfzzhW9DQu4QAPa7NUEhAEd+AV8Ah4CUzaXA6+LWDtwE6hxSVJvr/NADOgHHjidpGPvAW7YDvlibqgBJuwYj9sJrwNXdyCUj62YfucJO5xiCjBSJsmEiZ40UQoQIBQYukkyaWKkTITKEe3YEtSAW86URkpRVa/R0h3iUGMRRkqBgs2kSfl+jeZzISJNAQzDSm5jCNC8QCdQucVuxk0OHPFzaXgPZdU+4msZxvpWePMsTl2dxsWRMsK1PvSEyf2BFd4/SqEFTIB9QJfEag3AvlJaETlVRFm1D4BdpR5ar5QQ9AtaLoQI11q8FpRETqcwMZyXa5PAyWztBHilYGFeJ76WyXpVRjR6bu/l6NlgljMzGV5OxfD5lVOwUQLlTqYoKJmb2WTuRSLLaQHB8dYgpeXZ7mD23TKfZwJ4ZE4rV0jyut3rBRQ8H/3L6lIGN6QzacYGvrLbX7HNJoElJ2EqKC6RfJ/XeTu+4So4fW8RfTnsZlqSwGw+ayoIhQTTo+v8/pJTdBJ/TF7f8aB5g/lhAB8kMOlmkR5BMq54MrRmNbaNV3c32FhVbiEAk6K3YUEDvuHoRScMXdHcXcyxM0F+zOo8HV4nnVYIsc11ETgo7PHVCYwXSmukFD6/wEiZeLwC6dmuBnQBUQkwNF8VBQYLCfr8wv7KQmKDQBRyx9c1YLiQ6H8wYseSFew7/BMgA1zGmhqxHQjFsErVY8cC7hN7AnhsO7cDJ7B+fLAK/xHrCYji8gT8A4dR1BOLPGfhAAAAAElFTkSuQmCC', 'voi', '6', 'true'),
('0', 'voi:mainnet', 'voi', 'voi', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAACl0lEQVQ4jY2VwUtUURTGf/fOzBtncsTIQCfFIlPHiIpsIbTQFoU7BZVauIhaWrpK8g8IykUulCA3FrRxsLSIqISSCoKKQBEqJiLLdKWmzTjz3sy7Ld5zeDO+CT+4vMt3zvnOvYfzzhW9DQu4QAPa7NUEhAEd+AV8Ah4CUzaXA6+LWDtwE6hxSVJvr/NADOgHHjidpGPvAW7YDvlibqgBJuwYj9sJrwNXdyCUj62YfucJO5xiCjBSJsmEiZ40UQoQIBQYukkyaWKkTITKEe3YEtSAW86URkpRVa/R0h3iUGMRRkqBgs2kSfl+jeZzISJNAQzDSm5jCNC8QCdQucVuxk0OHPFzaXgPZdU+4msZxvpWePMsTl2dxsWRMsK1PvSEyf2BFd4/SqEFTIB9QJfEag3AvlJaETlVRFm1D4BdpR5ar5QQ9AtaLoQI11q8FpRETqcwMZyXa5PAyWztBHilYGFeJ76WyXpVRjR6bu/l6NlgljMzGV5OxfD5lVOwUQLlTqYoKJmb2WTuRSLLaQHB8dYgpeXZ7mD23TKfZwJ4ZE4rV0jyut3rBRQ8H/3L6lIGN6QzacYGvrLbX7HNJoElJ2EqKC6RfJ/XeTu+4So4fW8RfTnsZlqSwGw+ayoIhQTTo+v8/pJTdBJ/TF7f8aB5g/lhAB8kMOlmkR5BMq54MrRmNbaNV3c32FhVbiEAk6K3YUEDvuHoRScMXdHcXcyxM0F+zOo8HV4nnVYIsc11ETgo7PHVCYwXSmukFD6/wEiZeLwC6dmuBnQBUQkwNF8VBQYLCfr8wv7KQmKDQBRyx9c1YLiQ6H8wYseSFew7/BMgA1zGmhqxHQjFsErVY8cC7hN7AnhsO7cDJ7B+fLAK/xHrCYji8gT8A4dR1BOLPGfhAAAAAElFTkSuQmCC', 'voi', '6', 'true'),
('0', 'algo:testnet', 'algo', 'algo', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAB+klEQVQ4jaWVP4saYRDGHz3YdAEFyxUrKwu3USz8Blok0SVwQVNZilj4DSzOyj+pt7Qwh9hZqbCyn8AixkPuwIAgWLjLogb1SaEeRneNXB6YZt6ZH/O+M8wLWEsAIAOoA3gGsAZgAPhx8CUPMTfpA4AnAPyHPQH4eA10B+DhBtC5PRxyL/QW2Cn0LyWuJXg8HmqaxuFwyEgkYheXOMIEAJNrwGKxyKPy+bxd3C8Awh2AzwC+2j1sIBBArVbDcrnEer2G2+2GrutYLBYwDOM09D2AEQB8v1Zds9nkZrNhKpVivV7nbrfjZDJhKBSyin8EgBc7mCzLXK1WbLfbBMBqtUqSrFQqdDqdVjkvALCygrlcLvb7fW63W0qSRFEUORgMSJKFQsHuRmsA0K0Os9nsazUAWC6XXxvTarUoCIIt8Of5gc/n43g85nQ6pSiKDAaD1HWdqqqy1+txNpvR7/fbXvmiKaVSiSSZy+UIgN1ul6ZpMhwOM5PJkCRlWbZtyv2pMxqN0jAMappGQRCYTqdJko1GgwAYi8VomiYVRbECfgHOBltRFM7nc8bjcTocDnY6HY5GI0qSRAD0er1UVZX9ft9qsN8dhzJ5bRZvtCTOVPoPWOkcBuxXUO0NsG+wWV9HfcLtCzZhw7iQgH33H7H/An4f7Pngu4fNF/AHyizBiLQAefwAAAAASUVORK5CYII=', 'algo', '6', 'true'),
('0', 'algo:mainnet', 'algo', 'algo', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAB+klEQVQ4jaWVP4saYRDGHz3YdAEFyxUrKwu3USz8Blok0SVwQVNZilj4DSzOyj+pt7Qwh9hZqbCyn8AixkPuwIAgWLjLogb1SaEeRneNXB6YZt6ZH/O+M8wLWEsAIAOoA3gGsAZgAPhx8CUPMTfpA4AnAPyHPQH4eA10B+DhBtC5PRxyL/QW2Cn0LyWuJXg8HmqaxuFwyEgkYheXOMIEAJNrwGKxyKPy+bxd3C8Awh2AzwC+2j1sIBBArVbDcrnEer2G2+2GrutYLBYwDOM09D2AEQB8v1Zds9nkZrNhKpVivV7nbrfjZDJhKBSyin8EgBc7mCzLXK1WbLfbBMBqtUqSrFQqdDqdVjkvALCygrlcLvb7fW63W0qSRFEUORgMSJKFQsHuRmsA0K0Os9nsazUAWC6XXxvTarUoCIIt8Of5gc/n43g85nQ6pSiKDAaD1HWdqqqy1+txNpvR7/fbXvmiKaVSiSSZy+UIgN1ul6ZpMhwOM5PJkCRlWbZtyv2pMxqN0jAMappGQRCYTqdJko1GgwAYi8VomiYVRbECfgHOBltRFM7nc8bjcTocDnY6HY5GI0qSRAD0er1UVZX9ft9qsN8dhzJ5bRZvtCTOVPoPWOkcBuxXUO0NsG+wWV9HfcLtCzZhw7iQgH33H7H/An4f7Pngu4fNF/AHyizBiLQAefwAAAAASUVORK5CYII=', 'algo', '6', 'true'),
('718663983', 'algo:testnet', 'Test', 'test', null, 'asa', '6', 'false');
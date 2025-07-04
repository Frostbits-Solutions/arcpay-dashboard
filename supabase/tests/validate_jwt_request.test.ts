// -----------------------------------------------------------------------------
// validate_jwt_request.test.ts
//
// How to run:
//   cd supabase
//   npm run test
//
// Prerequisites:
//   - Supabase local development server running (default: http://127.0.0.1:54321)
//   - Create an account in public.accounts with 'authenticate_clients' set to true,
//     and note its ID.
//   - Create another account in public.accounts with 'authenticate_clients' set to false,
//     and note its ID.
//   - Associate a secret with the account (with 'authenticate_clients' set to true)
//     in public.accounts_secrets and not its secret.
//   - Ensure .env.development.local in the app folder contains the correct SUPABASE_ANON_KEY.
// -----------------------------------------------------------------------------

import { describe, it, expect } from 'vitest';
import dotenv from 'dotenv';
import jwt from 'jsonwebtoken';
import fetch from 'node-fetch';
dotenv.config({ path: '../app/.env.development.local' });

// ------------------- CONFIG -------------------
const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY;
const apiUrl = `${supabaseUrl}/rest/v1/rpc/validate_jwt_request`;
const testSecret = 'testSecret';
const accountJwtSecret = '27b0f9be-b08d-4f61-9686-c22682e487f0'; // Set your account secret here
const validAccountId = '843ab940-1e83-40b4-b359-837f386a34f8'; // Set a valid account ID with authenticate_clients set to true
const disabledAuthAccountId = 'dcb0a48a-82a9-42d1-9730-b19c484ab815'; // Set a valid account ID with authenticate_clients set to false
const now = Math.floor(Date.now() / 1000);

// Helper to generate a valid JWT for tests
function generateJwt(payload: object, secret: string, noTimestamp = false) {
  return jwt.sign(payload, secret, { algorithm: 'HS256', noTimestamp });
}

// ------------------- TESTS -------------------
describe('validate_jwt_request', () => {
  it('should error if missing x-arcpay-account-id', async () => {
    const token = generateJwt({ iat: now }, testSecret);
    const res = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'x-arcpay-jwt': token,
        'Content-Type': 'application/json'
      }
    });
    const data = await res.json();
    expect(res.status).toBe(400);
    expect(data.message).toMatch(/Missing x-arcpay-account-id/);
  });

  it('should error if missing x-arcpay-jwt', async () => {
    const res = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'x-arcpay-account-id': validAccountId,
        'Content-Type': 'application/json'
      }
    });
    const data = await res.json();
    expect(res.status).toBe(400);
    expect(data.message).toMatch(/Missing x-arcpay-jwt/);
  });

  it('should error for invalid account id', async () => {
    const token = generateJwt({ iat: now }, testSecret);
    const res = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'x-arcpay-account-id': 'invalid-id',
        'x-arcpay-jwt': token,
        'Content-Type': 'application/json'
      }
    });
    const data = await res.json();
    expect(res.status).toBe(400);
    expect(data.message).toMatch(/Invalid account id/);
  });

  it('should return authenticate_clients_false if authenticate_clients is false', async () => {
    const res = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'x-arcpay-account-id': disabledAuthAccountId,
        'x-arcpay-jwt': generateJwt({ iat: now }, testSecret),
        'Content-Type': 'application/json'
      }
    });
    expect(res.status).toBe(204);
  });

  it('should error for missing/invalid iat', async () => {
    // Missing iat
    const disableTimeline = true;
    let token = generateJwt({}, testSecret, disableTimeline);
    let res = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'x-arcpay-account-id': validAccountId,
        'x-arcpay-jwt': token,
        'Content-Type': 'application/json'
      }
    });
    let data = await res.json();
    expect(res.status).toBe(400);
    expect(data.message).toMatch(/Invalid or missing iat in JWT/);

    // iat in the future
    token = generateJwt({ iat: now + 100000 }, testSecret);
    res = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'x-arcpay-account-id': validAccountId,
        'x-arcpay-jwt': token,
        'Content-Type': 'application/json'
      }
    });
    data = await res.json();
    expect(res.status).toBe(400);
    expect(data.message).toMatch(/Invalid or missing iat in JWT/);
  });

  it('should error for expired JWT', async () => {
    const token = generateJwt({ iat: now - 10000, exp: now - 1 }, testSecret);
    const res = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'x-arcpay-account-id': validAccountId,
        'x-arcpay-jwt': token,
        'Content-Type': 'application/json'
      }
    });
    const data = await res.json();
    expect(res.status).toBe(400);
    expect(data.message).toMatch(/JWT is expired/);
  });

  it('should error for invalid JWT format', async () => {
    const res = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'x-arcpay-account-id': validAccountId,
        'x-arcpay-jwt': 'not.a.jwt',
        'Content-Type': 'application/json'
      }
    });
    const data = await res.json();
    expect(res.status).toBe(400);
    expect(data.message).toMatch(/Invalid JWT format/);
  });

  it('should error for invalid JWT signature', async () => {
    const token = generateJwt({ iat: now }, 'wrongsecret');
    const res = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'x-arcpay-account-id': validAccountId,
        'x-arcpay-jwt': token,
        'Content-Type': 'application/json'
      }
    });
    const data = await res.json();
    expect(res.status).toBe(400);
    expect(data.message).toMatch(/Cannot validate JWT signature/);
  });

  it('should return ok for valid JWT and account', async () => {
    const token = generateJwt({ iat: now, data: "Hello world !" }, accountJwtSecret);
    const res = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'x-arcpay-account-id': validAccountId,
        'x-arcpay-jwt': token,
        'Content-Type': 'application/json'
      }
    });
    expect(res.status).toBe(204);
  });
});

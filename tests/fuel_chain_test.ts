import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Test batch creation - owner only",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    // Test creation as owner
    let block = chain.mineBlock([
      Tx.contractCall('fuel-chain', 'create-batch', [
        types.uint(1000),
        types.ascii("Premium"),
        types.ascii("Cert123")
      ], deployer.address)
    ]);
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(1);
    
    // Test creation as non-owner (should fail)
    block = chain.mineBlock([
      Tx.contractCall('fuel-chain', 'create-batch', [
        types.uint(1000),
        types.ascii("Premium"),
        types.ascii("Cert123")
      ], wallet1.address)
    ]);
    block.receipts[0].result.expectErr().expectUint(100);
  }
});

Clarinet.test({
  name: "Test batch transfer",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    // Create batch
    let block = chain.mineBlock([
      Tx.contractCall('fuel-chain', 'create-batch', [
        types.uint(1000),
        types.ascii("Premium"),
        types.ascii("Cert123")
      ], deployer.address)
    ]);
    
    // Transfer batch
    block = chain.mineBlock([
      Tx.contractCall('fuel-chain', 'transfer-batch', [
        types.uint(1),
        types.principal(wallet1.address)
      ], deployer.address)
    ]);
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Verify transfer
    const response = chain.callReadOnlyFn(
      'fuel-chain',
      'get-batch-details',
      [types.uint(1)],
      deployer.address
    );
    response.result.expectOk().expectSome();
  }
});

Clarinet.test({
  name: "Test batch history tracking",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    // Create and transfer batch
    let block = chain.mineBlock([
      Tx.contractCall('fuel-chain', 'create-batch', [
        types.uint(1000),
        types.ascii("Premium"),
        types.ascii("Cert123")
      ], deployer.address),
      Tx.contractCall('fuel-chain', 'transfer-batch', [
        types.uint(1),
        types.principal(wallet1.address)
      ], deployer.address)
    ]);
    
    // Check history
    const response = chain.callReadOnlyFn(
      'fuel-chain',
      'get-batch-history',
      [types.uint(1)],
      deployer.address
    );
    response.result.expectOk();
  }
});

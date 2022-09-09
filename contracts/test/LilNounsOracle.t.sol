// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/LilNounsOracle.sol";
import "lil-nouns/NounsToken.sol";
import "lil-nouns/NounsSeeder.sol";
import "lil-nouns/NounsDescriptor.sol";

contract LilNounsOracleTest is Test {
    NounsToken lilNounsToken;
    NounsAuctionHouse auctionHouse;
    NounsSeeder seeder;
    NounsDescriptor descriptor;
    LilNounsOracle oracle;

    // Lil Noun 3935 was minted at block 15233857
    // See https://etherscan.io/tx/0x1c99ac9ee5ae42e48792c986b9d58251ac725aed744221b90db2a21c6ab1b641
    uint256 constant LIL_NOUN_3935_MINT_BLOCK = 15233857;

    // See https://etherscan.io/tx/0xd6c6dc31f969ad1e59cc54641a518512fc3c8c3dbe97770fc49e7ca9bafe9fd7
    uint256 constant AUCTION_HOUSE_DEPLOY_BLOCK = 14736713;

    address constant LIL_NOUNS_TOKEN_ADDRESS =
        0x4b10701Bfd7BFEdc47d50562b76b436fbB5BdB3B;
    address constant AUCTION_HOUSE_ADDRESS =
        0x55e0F7A3bB39a28Bd7Bcc458e04b3cF00Ad3219E;
    address constant SEEDER_ADDRESS =
        0xCC8a0FB5ab3C7132c1b2A0109142Fb112c4Ce515;
    address constant DESCRIPTOR_ADDRESS =
        0x11fb55d9580CdBfB83DE3510fF5Ba74309800Ad1;

    receive() external payable {}

    string MAINNET_RPC_URL;
    string expectedSvgFor3935 =
        "PHN2ZyB3aWR0aD0iMzIwIiBoZWlnaHQ9IjMyMCIgdmlld0JveD0iMCAwIDMyMCAzMjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc2hhcGUtcmVuZGVyaW5nPSJjcmlzcEVkZ2VzIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZDVkN2UxIiAvPjxyZWN0IHdpZHRoPSIxMDAiIGhlaWdodD0iMTAiIHg9IjExMCIgeT0iMjYwIiBmaWxsPSIjY2ZjMmFiIiAvPjxyZWN0IHdpZHRoPSIxMDAiIGhlaWdodD0iMTAiIHg9IjExMCIgeT0iMjcwIiBmaWxsPSIjY2ZjMmFiIiAvPjxyZWN0IHdpZHRoPSIyMCIgaGVpZ2h0PSIxMCIgeD0iMTEwIiB5PSIyODAiIGZpbGw9IiNjZmMyYWIiIC8+PHJlY3Qgd2lkdGg9IjcwIiBoZWlnaHQ9IjEwIiB4PSIxNDAiIHk9IjI4MCIgZmlsbD0iI2NmYzJhYiIgLz48cmVjdCB3aWR0aD0iMjAiIGhlaWdodD0iMTAiIHg9IjExMCIgeT0iMjkwIiBmaWxsPSIjY2ZjMmFiIiAvPjxyZWN0IHdpZHRoPSI3MCIgaGVpZ2h0PSIxMCIgeD0iMTQwIiB5PSIyOTAiIGZpbGw9IiNjZmMyYWIiIC8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjEwIiB4PSIxMTAiIHk9IjMwMCIgZmlsbD0iI2NmYzJhYiIgLz48cmVjdCB3aWR0aD0iNzAiIGhlaWdodD0iMTAiIHg9IjE0MCIgeT0iMzAwIiBmaWxsPSIjY2ZjMmFiIiAvPjxyZWN0IHdpZHRoPSIyMCIgaGVpZ2h0PSIxMCIgeD0iMTEwIiB5PSIzMTAiIGZpbGw9IiNjZmMyYWIiIC8+PHJlY3Qgd2lkdGg9IjcwIiBoZWlnaHQ9IjEwIiB4PSIxNDAiIHk9IjMxMCIgZmlsbD0iI2NmYzJhYiIgLz48cmVjdCB3aWR0aD0iMTAiIGhlaWdodD0iMTAiIHg9IjE0MCIgeT0iMjYwIiBmaWxsPSIjZmZjMTEwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMTgwIiB5PSIyNjAiIGZpbGw9IiNmZmMxMTAiIC8+PHJlY3Qgd2lkdGg9IjEwIiBoZWlnaHQ9IjEwIiB4PSIxNTAiIHk9IjI3MCIgZmlsbD0iI2ZmYzExMCIgLz48cmVjdCB3aWR0aD0iMTAiIGhlaWdodD0iMTAiIHg9IjE3MCIgeT0iMjcwIiBmaWxsPSIjZmZjMTEwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMTYwIiB5PSIyODAiIGZpbGw9IiNmZmMxMTAiIC8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjEwIiB4PSIxNjAiIHk9IjI5MCIgZmlsbD0iI2ZmYzExMCIgLz48cmVjdCB3aWR0aD0iMjAiIGhlaWdodD0iMTAiIHg9IjE1MCIgeT0iMzAwIiBmaWxsPSIjZmZjMTEwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMTUwIiB5PSI2MCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iMjAiIGhlaWdodD0iMTAiIHg9IjE0MCIgeT0iNzAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjEwIiB4PSIxNDAiIHk9IjgwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMTcwIiB5PSI4MCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iNDAiIGhlaWdodD0iMTAiIHg9IjEzMCIgeT0iOTAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjEwIiBoZWlnaHQ9IjEwIiB4PSI2MCIgeT0iMTAwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSI0MCIgaGVpZ2h0PSIxMCIgeD0iMTMwIiB5PSIxMDAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjEwIiBoZWlnaHQ9IjEwIiB4PSIyNDAiIHk9IjEwMCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iMjAiIGhlaWdodD0iMTAiIHg9IjYwIiB5PSIxMTAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjMwIiBoZWlnaHQ9IjEwIiB4PSIxNDAiIHk9IjExMCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iMTAiIGhlaWdodD0iMTAiIHg9IjE4MCIgeT0iMTEwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSIyMCIgaGVpZ2h0PSIxMCIgeD0iMjMwIiB5PSIxMTAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjMwIiBoZWlnaHQ9IjEwIiB4PSI2MCIgeT0iMTIwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMTAwIiB5PSIxMjAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjUwIiBoZWlnaHQ9IjEwIiB4PSIxMzAiIHk9IjEyMCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iMzAiIGhlaWdodD0iMTAiIHg9IjIyMCIgeT0iMTIwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSI0MCIgaGVpZ2h0PSIxMCIgeD0iNzAiIHk9IjEzMCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iNjAiIGhlaWdodD0iMTAiIHg9IjEzMCIgeT0iMTMwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSI0MCIgaGVpZ2h0PSIxMCIgeD0iMjAwIiB5PSIxMzAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjUwIiBoZWlnaHQ9IjEwIiB4PSI3MCIgeT0iMTQwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSI0MCIgaGVpZ2h0PSIxMCIgeD0iMTQwIiB5PSIxNDAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjUwIiBoZWlnaHQ9IjEwIiB4PSIxOTAiIHk9IjE0MCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iNTAiIGhlaWdodD0iMTAiIHg9IjgwIiB5PSIxNTAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjEwIiB4PSIxNDAiIHk9IjE1MCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iNDAiIGhlaWdodD0iMTAiIHg9IjE5MCIgeT0iMTUwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMjAiIHk9IjE2MCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iMTMwIiBoZWlnaHQ9IjEwIiB4PSI5MCIgeT0iMTYwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMjgwIiB5PSIxNjAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjEwIiB4PSIzMCIgeT0iMTcwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iNjAiIHk9IjE3MCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iMTEwIiBoZWlnaHQ9IjEwIiB4PSIxMDAiIHk9IjE3MCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iMjAiIGhlaWdodD0iMTAiIHg9IjI2MCIgeT0iMTcwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSI0MCIgaGVpZ2h0PSIxMCIgeD0iMzAiIHk9IjE4MCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iMTkwIiBoZWlnaHQ9IjEwIiB4PSI5MCIgeT0iMTgwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSIyMzAiIGhlaWdodD0iMTAiIHg9IjQwIiB5PSIxOTAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjE5MCIgaGVpZ2h0PSIxMCIgeD0iNjAiIHk9IjIwMCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iMTUwIiBoZWlnaHQ9IjEwIiB4PSI3MCIgeT0iMjEwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSIzMCIgaGVpZ2h0PSIxMCIgeD0iMTEwIiB5PSIyMjAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjEwIiBoZWlnaHQ9IjEwIiB4PSIxNDAiIHk9IjIyMCIgZmlsbD0iIzBiNTAyNyIgLz48cmVjdCB3aWR0aD0iNTAiIGhlaWdodD0iMTAiIHg9IjE1MCIgeT0iMjIwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSI1MCIgaGVpZ2h0PSIxMCIgeD0iMTAwIiB5PSIyMzAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjEwIiB4PSIxNTAiIHk9IjIzMCIgZmlsbD0iIzBiNTAyNyIgLz48cmVjdCB3aWR0aD0iNDAiIGhlaWdodD0iMTAiIHg9IjE3MCIgeT0iMjMwIiBmaWxsPSIjMDY4OTQwIiAvPjxyZWN0IHdpZHRoPSIxNTAiIGhlaWdodD0iMTAiIHg9IjgwIiB5PSIyNDAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjE3MCIgaGVpZ2h0PSIxMCIgeD0iNzAiIHk9IjI1MCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iMjAiIGhlaWdodD0iMTAiIHg9IjYwIiB5PSIyNjAiIGZpbGw9IiMwNjg5NDAiIC8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjEwIiB4PSIyMzAiIHk9IjI2MCIgZmlsbD0iIzA2ODk0MCIgLz48cmVjdCB3aWR0aD0iODAiIGhlaWdodD0iMTAiIHg9IjgwIiB5PSIxNDAiIGZpbGw9IiMwMDAwMDAiIC8+PHJlY3Qgd2lkdGg9IjgwIiBoZWlnaHQ9IjEwIiB4PSIxNzAiIHk9IjE0MCIgZmlsbD0iIzAwMDAwMCIgLz48cmVjdCB3aWR0aD0iMTAiIGhlaWdodD0iMTAiIHg9IjgwIiB5PSIxNTAiIGZpbGw9IiMwMDAwMDAiIC8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjEwIiB4PSI5MCIgeT0iMTUwIiBmaWxsPSIjZmZmZmZmIiAvPjxyZWN0IHdpZHRoPSI0MCIgaGVpZ2h0PSIxMCIgeD0iMTEwIiB5PSIxNTAiIGZpbGw9IiNmZjBlMGUiIC8+PHJlY3Qgd2lkdGg9IjEwIiBoZWlnaHQ9IjEwIiB4PSIxNTAiIHk9IjE1MCIgZmlsbD0iIzAwMDAwMCIgLz48cmVjdCB3aWR0aD0iMTAiIGhlaWdodD0iMTAiIHg9IjE3MCIgeT0iMTUwIiBmaWxsPSIjMDAwMDAwIiAvPjxyZWN0IHdpZHRoPSIyMCIgaGVpZ2h0PSIxMCIgeD0iMTgwIiB5PSIxNTAiIGZpbGw9IiNmZmZmZmYiIC8+PHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjEwIiB4PSIyMDAiIHk9IjE1MCIgZmlsbD0iI2ZmMGUwZSIgLz48cmVjdCB3aWR0aD0iMTAiIGhlaWdodD0iMTAiIHg9IjI0MCIgeT0iMTUwIiBmaWxsPSIjMDAwMDAwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iODAiIHk9IjE2MCIgZmlsbD0iIzAwMDAwMCIgLz48cmVjdCB3aWR0aD0iMjAiIGhlaWdodD0iMTAiIHg9IjkwIiB5PSIxNjAiIGZpbGw9IiNmZmZmZmYiIC8+PHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjEwIiB4PSIxMTAiIHk9IjE2MCIgZmlsbD0iI2ZmMGUwZSIgLz48cmVjdCB3aWR0aD0iMTAiIGhlaWdodD0iMTAiIHg9IjE1MCIgeT0iMTYwIiBmaWxsPSIjMDAwMDAwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMTcwIiB5PSIxNjAiIGZpbGw9IiMwMDAwMDAiIC8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjEwIiB4PSIxODAiIHk9IjE2MCIgZmlsbD0iI2ZmZmZmZiIgLz48cmVjdCB3aWR0aD0iNDAiIGhlaWdodD0iMTAiIHg9IjIwMCIgeT0iMTYwIiBmaWxsPSIjZmYwZTBlIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMjQwIiB5PSIxNjAiIGZpbGw9IiMwMDAwMDAiIC8+PHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjEwIiB4PSI1MCIgeT0iMTcwIiBmaWxsPSIjMDAwMDAwIiAvPjxyZWN0IHdpZHRoPSIyMCIgaGVpZ2h0PSIxMCIgeD0iOTAiIHk9IjE3MCIgZmlsbD0iI2ZmZmZmZiIgLz48cmVjdCB3aWR0aD0iNDAiIGhlaWdodD0iMTAiIHg9IjExMCIgeT0iMTcwIiBmaWxsPSIjZmYwZTBlIiAvPjxyZWN0IHdpZHRoPSIzMCIgaGVpZ2h0PSIxMCIgeD0iMTUwIiB5PSIxNzAiIGZpbGw9IiMwMDAwMDAiIC8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjEwIiB4PSIxODAiIHk9IjE3MCIgZmlsbD0iI2ZmZmZmZiIgLz48cmVjdCB3aWR0aD0iNDAiIGhlaWdodD0iMTAiIHg9IjIwMCIgeT0iMTcwIiBmaWxsPSIjZmYwZTBlIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMjQwIiB5PSIxNzAiIGZpbGw9IiMwMDAwMDAiIC8+PHJlY3Qgd2lkdGg9IjEwIiBoZWlnaHQ9IjEwIiB4PSI1MCIgeT0iMTgwIiBmaWxsPSIjMDAwMDAwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iODAiIHk9IjE4MCIgZmlsbD0iIzAwMDAwMCIgLz48cmVjdCB3aWR0aD0iMjAiIGhlaWdodD0iMTAiIHg9IjkwIiB5PSIxODAiIGZpbGw9IiNmZmZmZmYiIC8+PHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjEwIiB4PSIxMTAiIHk9IjE4MCIgZmlsbD0iI2ZmMGUwZSIgLz48cmVjdCB3aWR0aD0iMTAiIGhlaWdodD0iMTAiIHg9IjE1MCIgeT0iMTgwIiBmaWxsPSIjMDAwMDAwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMTcwIiB5PSIxODAiIGZpbGw9IiMwMDAwMDAiIC8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjEwIiB4PSIxODAiIHk9IjE4MCIgZmlsbD0iI2ZmZmZmZiIgLz48cmVjdCB3aWR0aD0iNDAiIGhlaWdodD0iMTAiIHg9IjIwMCIgeT0iMTgwIiBmaWxsPSIjZmYwZTBlIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMjQwIiB5PSIxODAiIGZpbGw9IiMwMDAwMDAiIC8+PHJlY3Qgd2lkdGg9IjEwIiBoZWlnaHQ9IjEwIiB4PSI1MCIgeT0iMTkwIiBmaWxsPSIjMDAwMDAwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iODAiIHk9IjE5MCIgZmlsbD0iIzAwMDAwMCIgLz48cmVjdCB3aWR0aD0iMjAiIGhlaWdodD0iMTAiIHg9IjkwIiB5PSIxOTAiIGZpbGw9IiNmZmZmZmYiIC8+PHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjEwIiB4PSIxMTAiIHk9IjE5MCIgZmlsbD0iI2ZmMGUwZSIgLz48cmVjdCB3aWR0aD0iMTAiIGhlaWdodD0iMTAiIHg9IjE1MCIgeT0iMTkwIiBmaWxsPSIjMDAwMDAwIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMTcwIiB5PSIxOTAiIGZpbGw9IiMwMDAwMDAiIC8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjEwIiB4PSIxODAiIHk9IjE5MCIgZmlsbD0iI2ZmZmZmZiIgLz48cmVjdCB3aWR0aD0iNDAiIGhlaWdodD0iMTAiIHg9IjIwMCIgeT0iMTkwIiBmaWxsPSIjZmYwZTBlIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMjQwIiB5PSIxOTAiIGZpbGw9IiMwMDAwMDAiIC8+PHJlY3Qgd2lkdGg9IjEwIiBoZWlnaHQ9IjEwIiB4PSI4MCIgeT0iMjAwIiBmaWxsPSIjMDAwMDAwIiAvPjxyZWN0IHdpZHRoPSIyMCIgaGVpZ2h0PSIxMCIgeD0iOTAiIHk9IjIwMCIgZmlsbD0iI2ZmZmZmZiIgLz48cmVjdCB3aWR0aD0iNDAiIGhlaWdodD0iMTAiIHg9IjExMCIgeT0iMjAwIiBmaWxsPSIjZmYwZTBlIiAvPjxyZWN0IHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgeD0iMTUwIiB5PSIyMDAiIGZpbGw9IiMwMDAwMDAiIC8+PHJlY3Qgd2lkdGg9IjEwIiBoZWlnaHQ9IjEwIiB4PSIxNzAiIHk9IjIwMCIgZmlsbD0iIzAwMDAwMCIgLz48cmVjdCB3aWR0aD0iMjAiIGhlaWdodD0iMTAiIHg9IjE4MCIgeT0iMjAwIiBmaWxsPSIjZmZmZmZmIiAvPjxyZWN0IHdpZHRoPSI0MCIgaGVpZ2h0PSIxMCIgeD0iMjAwIiB5PSIyMDAiIGZpbGw9IiNmZjBlMGUiIC8+PHJlY3Qgd2lkdGg9IjEwIiBoZWlnaHQ9IjEwIiB4PSIyNDAiIHk9IjIwMCIgZmlsbD0iIzAwMDAwMCIgLz48cmVjdCB3aWR0aD0iODAiIGhlaWdodD0iMTAiIHg9IjgwIiB5PSIyMTAiIGZpbGw9IiMwMDAwMDAiIC8+PHJlY3Qgd2lkdGg9IjgwIiBoZWlnaHQ9IjEwIiB4PSIxNzAiIHk9IjIxMCIgZmlsbD0iIzAwMDAwMCIgLz48L3N2Zz4=";

    function setUp() public {
        MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        auctionHouse = NounsAuctionHouse(AUCTION_HOUSE_ADDRESS);
        lilNounsToken = NounsToken(LIL_NOUNS_TOKEN_ADDRESS);
        descriptor = NounsDescriptor(DESCRIPTOR_ADDRESS);
    }

    // Helpers
    function deployLilNounsOracle() public returns (LilNounsOracle) {
        return
            new LilNounsOracle(
                address(AUCTION_HOUSE_ADDRESS),
                address(SEEDER_ADDRESS),
                address(DESCRIPTOR_ADDRESS)
            );
    }

    // Used to test negative assertions (assertNotEqual does not exist)
    function svgIsLilNoun3935(string memory svg3935)
        public
        view
        returns (bool)
    {
        // Compare hashes because Solidity doesn't support string equality'
        // comparison
        return
            keccak256(abi.encodePacked(expectedSvgFor3935)) ==
            keccak256(abi.encodePacked(svg3935));
    }

    // Tests
    //
    // testForkingBehavior does not test the LilNounsOracle contract.
    // It is included to establish/verify how fork testing can be
    // expected to work for other tests the other tests.
    function testForkingBehavior() public {
        // The goal of this test is to verify that the blockchain state after
        // running vm.rollFork(blockNumberX) includes all transactions at
        // blockNumberX
        vm.createSelectFork(MAINNET_RPC_URL);
        vm.rollFork(LIL_NOUN_3935_MINT_BLOCK);
        assertEq(block.number, LIL_NOUN_3935_MINT_BLOCK);

        // If forks that is set to blockNumberX includes all transactions in
        // blockNumberX,
        // we'd expect the next nounId to be 3936
        oracle = deployLilNounsOracle();
        (uint256 blockNumber, uint256 nextNounId, , ) = oracle
            .fetchNextNounAndAuctionState();
        assertEq(blockNumber, LIL_NOUN_3935_MINT_BLOCK);
        assertEq(nextNounId, 3936); // Verified fork behavior

        // Also double check the svg is the expected svg at this block
        (
            uint48 background,
            uint48 body,
            uint48 access,
            uint48 head,
            uint48 glasses
        ) = lilNounsToken.seeds(3935);
        INounsSeeder.Seed memory seed3935 = INounsSeeder.Seed(
            background,
            body,
            access,
            head,
            glasses
        );
        string memory svg3935 = descriptor.generateSVGImage(seed3935);
        assertTrue(svgIsLilNoun3935(svg3935));
    }

    function testOnlyOwnerCanSetFeeAmount() public {
        oracle = deployLilNounsOracle();
        assertEq(oracle._feeAmount(), 0);
        assertEq(oracle.owner(), address(this));

        // Owner can set fee amount
        oracle.setFeeAmount(1 ether);
        assertEq(oracle._feeAmount(), 1 ether);

        // Non owners cannot set fee amount
        vm.prank(address(0));
        vm.expectRevert("Ownable: caller is not the owner");
        oracle.setFeeAmount(2 ether);
    }

    function testCanReceiveTransfersAndOwnerCanWithdraw() public {
        uint256 initialBalance = address(this).balance;
        oracle = deployLilNounsOracle();

        // Contract should be able to receive an ether
        payable(address(oracle)).transfer(1 ether);
        assertEq(address(oracle).balance, 1 ether);
        assertEq(address(this).balance, initialBalance - 1 ether);

        // Owner should be able to withdraw the ether
        oracle.withdraw();
        assertEq(address(this).balance, initialBalance);
    }

    function testNonOwnerCantWithdraw() public {
        oracle = deployLilNounsOracle();
        payable(address(oracle)).transfer(1 ether);
        vm.prank(address(0));
        vm.expectRevert("Ownable: caller is not the owner");
        oracle.withdraw();
    }

    function testSettleCurrentAndCreateNewAuctionExpectedBlockValid() public {
        vm.createSelectFork(MAINNET_RPC_URL);
        vm.rollFork(LIL_NOUN_3935_MINT_BLOCK - 1);
        oracle = deployLilNounsOracle();
        (uint256 nounIdBeforeSettle, , , , , ) = auctionHouse.auction();
        assertEq(nounIdBeforeSettle, 3934);
        oracle.settleCurrentAndCreateNewAuction(LIL_NOUN_3935_MINT_BLOCK - 1);

        // Verify the nounId in the auction
        uint256 nounIdAfterSettle;
        (nounIdAfterSettle, , , , , ) = auctionHouse.auction();
        assertEq(nounIdBeforeSettle + 1, nounIdAfterSettle);
    }

    function testSettleCurrentAndCreateNewAuctionExpectedBlockInvalid() public {
        vm.createSelectFork(MAINNET_RPC_URL);
        vm.rollFork(LIL_NOUN_3935_MINT_BLOCK); // Already minted
        oracle = deployLilNounsOracle();
        (uint256 nounIdBeforeSettle, , , , , ) = auctionHouse.auction();

        // If block.number != expectedBlock, the transaction should revert
        vm.expectRevert("Refused to start auction: desired Lil Noun expired.");
        oracle.settleCurrentAndCreateNewAuction(LIL_NOUN_3935_MINT_BLOCK - 1);
        uint256 nounIdAfterSettle;
        (nounIdAfterSettle, , , , , ) = auctionHouse.auction();
        assertEq(nounIdBeforeSettle, nounIdAfterSettle);
    }

    function testCanReceiveAndWithdrawFees() public {
        vm.createSelectFork(MAINNET_RPC_URL);
        vm.rollFork(LIL_NOUN_3935_MINT_BLOCK - 1);
        oracle = deployLilNounsOracle();
        uint256 deployerInitialBalance = address(this).balance;
        uint256 oracleInitialBalance = address(oracle).balance;

        // Should be able to send value without reverting
        oracle.settleCurrentAndCreateNewAuction{value: 1 ether}(
            LIL_NOUN_3935_MINT_BLOCK - 1
        );
        assertEq(address(oracle).balance, oracleInitialBalance + 1 ether);
        assertEq(address(this).balance, deployerInitialBalance - 1 ether);

        // Owner should be able to withdraw
        oracle.withdraw();
        assertEq(address(oracle).balance, 0);
        assertGt(address(this).balance, deployerInitialBalance - 0.01 ether); // Got some funds back
    }

    function testRefusesTransfersWithCallData() public {
        oracle = deployLilNounsOracle();
        vm.expectRevert("revert");
        (bool sent, ) = payable(address(oracle)).call{value: 1 ether}(
            "calldata"
        );
        assertFalse(sent);
    }

    function testFetchNextNounSvg() public {
        // Goal of this test is to verify LilNounsOracle
        // contract accurately calculates the next noun ID svg if
        // fetchNextNounAndAuctionState is called with blocktag='pending'

        // Roll state to block one block before 3935 is minted
        vm.createSelectFork(MAINNET_RPC_URL);
        vm.rollFork(LIL_NOUN_3935_MINT_BLOCK - 1);
        oracle = deployLilNounsOracle();
        (
            uint256 blockNumber,
            uint256 nextNounId,
            string memory svg3935,

        ) = oracle.fetchNextNounAndAuctionState();
        assertEq(blockNumber, LIL_NOUN_3935_MINT_BLOCK - 1);
        assertEq(nextNounId, 3935);

        // Expect not equal because the calculation is using
        // LIL_NOUN_3935_MINT_BLOCK-1  as the block.number but 3935 was actually
        // minted with the following that block.number + 1
        assertFalse(svgIsLilNoun3935(svg3935));

        // Update only block.number to LIL_NOUN_3935_MINT_BLOCK, and but otherwise
        // keep the state of the previous block
        vm.roll(LIL_NOUN_3935_MINT_BLOCK); // Note: vm.roll() is not vm.rollFork()

        // The current state effectively simulates LIL_NOUN_3935_MINT_BLOCK
        // during the 'pending' state: it has all the state of 0x...56, but
        // all calls are made in the context of block.number being 0x...57.
        //
        // This is how the frontend will fetch the next noun SVG,
        // by passing blockTag='pending'.
        (blockNumber, nextNounId, svg3935, ) = oracle
            .fetchNextNounAndAuctionState();
        assertEq(blockNumber, LIL_NOUN_3935_MINT_BLOCK);
        assertEq(nextNounId, 3935);
        assertTrue(svgIsLilNoun3935(svg3935));
    }

    function testFetchAuctionState() public {
        vm.createSelectFork(MAINNET_RPC_URL);
        // Block 0x...56 is one block before 3935 is minted.
        // The auction state should be OVER_NOT_SETTLED
        vm.rollFork(LIL_NOUN_3935_MINT_BLOCK - 1);
        oracle = deployLilNounsOracle();
        (, , , LilNounsOracle.AuctionState auctionState) = oracle
            .fetchNextNounAndAuctionState();
        assertEq(uint256(auctionState), 2);

        // Roll one block to 0x..57 which includes the minting of 3935
        // and thus kicks of the auction
        vm.rollFork(LIL_NOUN_3935_MINT_BLOCK);
        oracle = deployLilNounsOracle();
        (, , , auctionState) = oracle.fetchNextNounAndAuctionState();
        assertEq(uint256(auctionState), 1);

        // Roll to block in which the auction house contract was deployed.
        // This is the only time the auction state is NOT_STARTED
        vm.rollFork(AUCTION_HOUSE_DEPLOY_BLOCK);
        oracle = deployLilNounsOracle();
        (, , , auctionState) = oracle.fetchNextNounAndAuctionState();
        assertEq(uint256(auctionState), 0);
    }
}

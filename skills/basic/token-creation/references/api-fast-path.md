# API Fast Path

Use this reference for the fastest path to a finished token launch.

## Default Choice

Prefer this path when the user says things like:

- launch a coin
- create a token quickly
- get a memecoin live

## Required Inputs

- chain slug
- `name`
- `symbol`
- `description`
- token image source
- creator identity if attribution matters

## Example Prompts

- Launch a token on Base using the API fast path.
- Give me the exact requests for the fastest Flaunch token launch flow.
- What are the minimum inputs for a memecoin launch through the Web2 API?

## Execution Route

1. Convert the image to `base64Image`.
2. Call `POST /api/v1/upload-image`.
3. Use the returned `ipfsHash` as `imageIpfs`.
4. Call `POST /api/v1/{chain}/launch-memecoin`.
5. Save the `jobId`.
6. Poll `GET /api/v1/launch-status/{jobId}` until `completed` or `failed`.
7. Return the final `transactionHash` and launched token address.

## When To Switch Away

Switch to the SDK path if the user needs:

- wallet-controlled launch transactions
- a TypeScript app or script
- launch result parsing inside their own app
- trading, liquidity, or import flows around the token

## Minimum Output

When answering from this skill, include:

- exact API endpoints
- required fields
- async polling behavior
- final success fields

# Revenue Manager Flow

Use this reference for the Web2 API revenue-manager creation path.

## Best Fit

Choose this path when the builder wants:

- a hosted API route for creating revenue managers
- creator revenue plus protocol recipient behavior
- backend-assisted manager creation instead of direct contract integration

## Required Inputs

- chain route slug: `base` or `base-sepolia`
- protocol recipient identity
- `protocolFee` in basis points
- optional owner override

## Example Prompts

- Create a revenue manager on Base with a 5% protocol fee to `0xabc...`.
- Show the request body for `create-revenue-manager` on Base Sepolia.
- Explain the required inputs for a Flaunch revenue manager API call.

## Endpoint

- `POST /api/v1/{chain}/create-revenue-manager`

## Execution Route

1. Resolve the chain slug first.
2. Choose the protocol recipient identity path.
3. Validate `protocolFee` is within the supported range.
4. Add the optional owner override only if needed.
5. Submit the request.
6. Capture the returned manager address or creation result.

## Validation Rules

- `protocolFee` must be within the API-supported bounds
- use a valid recipient identity payload
- do not mix fee-split-only fields into revenue-manager requests

## Output Requirements

A complete answer should include:

- exact endpoint path
- required request fields
- protocol fee constraints
- expected success output
- one likely validation or request error

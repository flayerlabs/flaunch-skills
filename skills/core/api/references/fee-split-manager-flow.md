# Fee Split Manager Flow

Use this reference for the Web2 API fee-split manager creation path.

## Best Fit

Choose this path when the builder wants:

- a hosted API route for creating fee-split managers
- recipient identity resolution through wallet, email, Twitter, or Farcaster
- backend-assisted manager creation without direct contract deployment code

## Required Inputs

- chain route slug: `base` or `base-sepolia`
- manager owner identity
- recipient list
- optional `creatorShare`
- optional `ownerShare`
- custom `split` values if not using equal/default behavior

## Example Prompts

- Create a fee split manager on Base that routes all fees to `0xabc...`.
- Show the request body for `create-fee-split-manager` with three recipients and custom splits.
- Explain the validation rules for a fee-split manager request on Base Sepolia.

## Endpoint

- `POST /api/v1/{chain}/create-fee-split-manager`

## Execution Route

1. Resolve the chain slug first.
2. Build the owner identity payload.
3. Build the recipient array using supported identity types.
4. If any recipient uses a custom `split`, require all recipients to provide one.
5. Submit the manager creation request.
6. Capture the returned manager address or creation result.

## Validation Rules

- recipient limit applies
- duplicate resolved wallet addresses are rejected
- if one recipient specifies `split`, every recipient must specify `split`
- total recipient `split` values must equal `10,000,000`
- do not combine incompatible manager options in the same request

## Output Requirements

A complete answer should include:

- exact endpoint path
- required request fields
- share validation rules
- expected success output
- one likely error path

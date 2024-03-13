"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "0.11.0-rc1": {
        "aarch64-apple-darwin": "sha384-TrYFcd8iG2mhFnWSQq6fYpShylqW13m+5n2dfswFPJbkLk55wf58e71pD54JkmuG",
        "aarch64-unknown-linux-musl": "sha384-Cnu+YuXYA+7HU8uXh6C1uzWFkx8diueFivrYuea3jcpD8pfO3wOVIKR4Zn6pMoYZ",
        "armv7-unknown-linux-musleabi": "sha384-vM8JZM2CHGXBHREXQgac4E5OuoH+OFJjnPl4jBHusZov0kOX5a1sfEFLVJa5VdNg",
        "x86_64-apple-darwin": "sha384-4xqXCvPk8ltOliWLJGKNV1u830LIBoqYWDuLAauv5FPF9x7/e4mt3yj9ZAq+ZIW9",
        "x86_64-pc-windows-msvc": "sha384-pJJM9C1kOV8qlThEcumVtJ0+uuahww7D8MGnmWOZaVKcWbN5OYSCdpGodlcyUNZ/",
        "x86_64-unknown-linux-musl": "sha384-E4xPR0vNZv8CY0ceSgPiEcS2joF2oKoffL1SDjJQQNbNeSQ4h71MOv/ib+JEu27M",
    },
}

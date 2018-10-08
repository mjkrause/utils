# Fullstack APIs

## Argon

This is a bit complicated as you need two tokens, one to download the BDBag, and a second to download the data files (CRAM, CRAI).

### Preparation
Create a JSON file like so
```JSON
{
  "personal_UUID": "",
  "scope_bdbag": "",
  "scope_results": "",
  "token_bdbag": "",
  "token_results": ""
}
```
and name it `mykeychain.json` and populate it with the personal UUID and the scopes for the BDBag and results. Then write values to `bash` variables
```bash
pers_uuid=$(jq -r .personal_UUID mykeychain.json)
scope_bdbag=$(jq -r .scope_bdbag mykeychain.json)
scope_results=$(jq -r .scope_results mykeychain.json)
```

### Get authentication script
Clone the authentication script (from master) from [here](https://github.com/rpwagner/oauth_cli_login), create a Python3 virtual environment, run `pip install globus_sdk` and run
```bash
python example.py $scope_bdbag $pers_uuid
```
and follow the directions. From the resulting JSON file, which resides in 
`~/.globus-native-app/1b0dc9d3-0a2b-4000-8bd6-90fb6a79be86/`

copy the value of the `access_token` to `token_bdbag`. Then repeat the same using `$scope_results`. Now you have the tokens needed.

### Download BDBag
Assign the URL to the BDBag to a shell variable named `bdbag_url` and run
```bash
wget -L -H "Authorization: Bearer $token_bdbag" $bdbag_url
```

### Using Mike D'Arcy's `bdbag`
(as of 2018-10-08)
Once you have the two tokens make `~/.bdbag/keychain.json` look like so
```JSON[
  {
    "uri": "https://bags.fair-research.org/",
    "auth_type": "bearer-token",
    "auth_params": {
      "token": "<bag_token>",
      "allow_redirects_with_token": "True"
    }
  },
  {
    "uri": "https://results.fair-research.org/",
    "auth_type": "bearer-token",
    "auth_params": {
      "token": "<results_token>",
      "allow_redirects_with_token": "True"
    }
  }
]
```

[`bdbag`](https://github.com/fair-research/bdbag/tree/dev_branch_1_5) can now download the bag, unzip it, and then download the CRAM the URL in `fetch.txt` points to. Suppose shell variable `bag_url` holds the URI to the BDBag. Then do 
```bash
bdbag --materialize $bag_url
```
to achieve this.



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
and follow the directions. From the resulting JSON file copy the value of the `access_token` to `token_bdbag`. Then repeat the same using `$scope_results`. Now you have the tokens needed.




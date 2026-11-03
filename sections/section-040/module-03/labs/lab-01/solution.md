# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-03/labs/lab-01
```

## Step 1: Print the file

```sh
kubectl -n starfleet get configmap schema-file -o jsonpath='{.data.schema\.yaml}'
```

## Step 2: Review it

Run `grep -n '^schema_url:'` on the text: nothing is printed, so the field is missing. Run `grep -n 'rename_'`: one hit reads `rename_attribute:` without the final `s`. Look at the second map: its line starts with a dash, so the map is a list.

## Step 3: Fix the ConfigMap

```sh
kubectl -n starfleet edit configmap schema-file
```

Add `schema_url: https://schemas.example.com/starfleet/1.2.0` after `file_format`. Change `rename_attribute` to `rename_attributes`. Remove the dash in front of `crew.id: member.id`. Save and run the greps again.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-03/labs/lab-01 --keep
```

All checks pass.

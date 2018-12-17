# win-printer-drivers

Ensure a Printer Drivers are installed

> CAUTION! This role is a version for a internal System, it is not maintaned or supported by me(@daBONDi)

> **Use it only as reference and ideas** (Community you know?)

> Depending on Host Var **printer_drivers** or passed manualy
> Depending on print_service.driver_store or driver_store passed manualy or use default

- Download and extract Printer Drivers
- Import Driver files **driver_setup.inf_file** with pnputil
- Add Printer Driver with name depending on **driver_setup.name**

## Role Parameters

| Name            | Description                                                                                        |
| --------------- | -------------------------------------------------------------------------------------------------- |
| driver_store    | Where to Store ther Drivers (**Default: c:\data\drivers**, or host_var print_service.driver_store) |
| printer_drivers | Hostvar list of printer_drivers elements                                                           |

## Description - printer_drivers element

| Name                    | Description                                                     | Required | Default    |
| ----------------------- | --------------------------------------------------------------- | -------- | ---------- |
| driver_name             | Name of the Driver to manage it in driver_store                 | Yes      |            |
| download_url            | URL where to Download the driver                                | Yes      |            |
| download_url_user       | User for authenticating agains the webserver                    | Yes      |            |
| download_url_password   | Password for authenticating agains the webserver                | Yes      |            |
| driver_setup.name       | Drivername from inf file to use                                 | Yes      |            |
| driver_setup.inf_file   | Name of the INF File in the Driver Package                      | Yes      |            |
| driver_setup.print_env  | For what Environment the Printer Driver is used (x86/**x64**)   | No       | x64        |

## printer_drivers Example

```yaml
printer_drivers:
  - driver_name: "hp-upd-pcl6-x64-6.6.0.23029"
    download_url: "{{ global_infra_store_software_repo_url }}/drivers/printer/hp-upd-pcl6-x64-6.6.0.23029.zip"
    download_url_user: "{{ global_infra_store_username }}"
    download_url_password: "{{ global_infra_store_password }}"
    driver_setup:
      name: "HP Universal Printing PCL 6 (v6.6.0)" # Needs to be the same name as in inf file present
      inf_file: "hpcu215u.inf"
      printer_env: "x64"
```

## Example

```yaml
   - include_role:
        name: win-printer-driver
      vars:
        printer_drivers:
          - driver_name: "hp-upd_pcl6-x86-6.6.0.23029"
            download_url: "{{ global_infra_store_software_repo_url }}/drivers/printer/hp-upd_pcl6-x86-6.6.0.23029.zip"
            download_url_user: "DownloadUser"
            download_url_password: "ExtremSecrentPassword"
            driver_setup: 
              name: "HP Universal Printing PCL 6 (v6.6.0)" # Needs to be the same name as in inf file present
              inf_file: "hpcu215c.inf"
              printer_env: "x86"  # x64 = default | x86
            driver_store: "{{ print_service.driver_store }}"
```
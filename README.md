# Fetch and add ssh public keys

One task that is asked of me very frequently is to add people's `ssh` public
keys; so I am doing the same commands over and over... So I mean there must
be an easier way... This is a tiny script that fetches a user `ssh` key from 
a `URL` and adds it to the `authorized_keys` file; usage is simple as is 
shown below:

```bash
$ ./fetch_my_key.sh my_user my_key_url
```

If the provided user is not available, we try to create it; at the moment this 
only supports the CL user creation scheme used for managed servers hosted in the 
University of Cambridge...

# Permissions

Please run this script using `sudo` and also give it execution permissions (`+x`) as
is shown below:

```
$ chmod +x ./fetch_my_key.sh
```

# Dropbox links

One usual way of hosting the public keys is to have them in `Dropbox`; but when
sharing from `Dropbox` adds either a `?dl=0` or `?dl=1' in the end of the file,
hence the links looks like this:

```
https://www.dropbox.com/s/meg5651mbx0ajx5/my_key?dl=0
```

`wget` gets a bit confused by this so in order to fix it just remove the `?dl=0`
part from the link so it looks like this:

```
https://www.dropbox.com/s/meg5651mbx0ajx5/my_key
```
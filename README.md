# Fetch and add ssh public keys

One task that is asked of me very frequently is to add people's `ssh` public
keys; so I am doing the same commands over and over... There must
be an easier way... this is a tiny script that fetches a user `ssh` key from 
a `URL` and adds it to the `authorized_keys` file.

The script supports two modes:

 - Fetch key from URL - such as from Dropbox, Google drive, or other remote location.
 - Use key from shell argument -- i.e. directly paste it in the command line.

# Initial stuff.

First of all you have to clone this repo using the following command:

```
$ git clone https://github.com/andylamp/fetch_my_key
```

Go in `fetch_my_key` folder and give it execution permissions as is shown
below:

```
$ chmod +x ./fetch_my_key.sh
```

Then you are ready to run this script as is shown next.

# Running the script.

To run the script you have to put the `userid` (usually, the raven id).
Additionally we require the location of the key from a publicly available `url` or directly pasting it in the terminal as a parameter. 
If the provided user is not available, it tries to create it; at the moment this only supports the CL user creation scheme used for managed servers hosted in the University of Cambridge.

## Using remote URL

The following syntax should be used when fetching an ssh key from a remote URL:

```bash
$ sudo ./fetch_my_key.sh my_user my_key_url
```

## Using embedded key

The following syntax should be used when embedding the key directly in the terminal:

```bash
$ sudo ./fetch_my_key.sh my_user "<ssh-key-contents>"
```

# Dropbox links.

One widely used way of hosting the public keys is to have them in `Dropbox`; but when
sharing from `Dropbox` adds either a `?dl=0` or `?dl=1` in the end of the file,
hence the links looks like this:

```
https://www.dropbox.com/s/meg5651mbx0ajx5/my_key?dl=0
```

`wget` gets a bit confused by this so in order to fix it just remove the `?dl=x`
part from the link so it looks like this:

```
https://www.dropbox.com/s/meg5651mbx0ajx5/my_key
```
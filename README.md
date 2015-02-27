# Figure

Fig powered mini-Heroku. Inspired by [Dokku](https://github.com/progrium/dokku).

## What is it?

This project started as a fork of [Dokku](https://github.com/progrium/dokku). It can host any application that can be run by `fig up` by [Fig](https://github.com/docker/fig) locally.

## Demo

This demo shows how easy it is to deploy the [Let's Chat](https://github.com/sdelements/lets-chat) program. It's applicable to any program that supports Fig.

1. Follow the Installation guide to fire up a Figure server, or run `vagrant up` (with [Vagrant](https://www.vagrantup.com/) installed) for a local development server.
2. Clone the Let's Chat repo `git clone https://github.com/sdelements/lets-chat`.
3. Figure requires a service named `web` defined in `fig.yml`. So you need to change the fig.yml slightly. Also, you can create a volume for mongo to keep the data. The final fig.yml may look as follows:

    ```
    # Let's Chat application
    web:
      build: .
      links:
        - db:db
      ports:
        - 5000:5000

    # Mongo Database
    db:
      image: mongo:latest
      volumes:
        - .docker/db:/data/db
    ```

4. Commit the fig.yml file. Add Figure server for pushing.

    ```
    git add fig.yml
    git commit -m "adopt for figure deployment"
    git remote add figure figure@<your-server-address>:<app-name>
    ```

5. Run `git push`. The application will be live at `http://<app-name>.<your-server-address>`.

## Installation

The current version of Figure only supports Ubuntu. To install it on your server:

1. Install `make`, `git` and `ruby`.
2. If you want to run this on AWS, follow the instruction [here](https://github.com/dokku-alt/dokku-alt/issues/126) to enable AUFS.
3. Clone the repo by `git clone https://github.com/project-nsmg/figure`.
4. Run `make install` as root.
5. Run `cat ~/.ssh/id_rsa.pub | ssh {YOUR_SERVER_IP} "sudo sshcommand acl-add figure $USER"` in your local server to upload your public key.
6. Add `figure ALL=(ALL) NOPASSWD:ALL` to sudoer file.
7. Change content in `/home/figure/VHOST` to the domain you want to serve.

That's it!

## Figure Commands

Following the same design principle of Dokku, you need to run figure commands through ssh, like `ssh figure@your-server-address <your-command>`. Run `ssh figure@your-server-address help` for all available commands.

## Is It Suitable For Production?

Figure is powering http://ns.mg and http://snapviva.com, but it is still in a very early stage. Many functions may not work as expected.

## License

MIT

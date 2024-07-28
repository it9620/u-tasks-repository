# u_tasks_repository

This project based on template of a C++ service that uses [userver framework](https://github.com/userver-framework/userver) with PostgreSQL.

This project is targeting on Ubuntu 24. It's must also posibly builded on macos. But seems not suport Windows system (because no support from userver).

Authored by Maliuga Andrei.

---

## Makefile

Makefile contains typicaly useful targets for development:

* `make build-debug` - debug build of the service with all the assertions and sanitizers enabled
* `make build-release` - release build of the service with LTO
* `make test-debug` - does a `make build-debug` and runs all the tests on the result
* `make test-release` - does a `make build-release` and runs all the tests on the result
* `make service-start-debug` - builds the service in debug mode and starts it
* `make service-start-release` - builds the service in release mode and starts it
* `make` or `make all` - builds and runs all the tests in release and debug modes
* `make format` - autoformat all the C++ and Python sources
* `make clean-` - cleans the object files
* `make dist-clean` - clean all, including the CMake cached configurations
* `make install` - does a `make build-release` and runs install in directory set in environment `PREFIX`
* `make install-debug` - does a `make build-debug` and runs install in directory set in environment `PREFIX`
* `make docker-COMMAND` - run `make COMMAND` in docker environment
* `make docker-build-debug` - debug build of the service with all the assertions and sanitizers enabled in docker environment
* `make docker-test-debug` - does a `make build-debug` and runs all the tests on the result in docker environment
* `make docker-start-service-release` - does a `make install-release` and runs service in docker environment
* `make docker-start-service-debug` - does a `make install-debug` and runs service in docker environment
* `make docker-clean-data` - stop docker containers and clean database data

Edit `Makefile.local` to change the default configuration and build options.

---

## License

The original template is distributed under the [Apache-2.0 License](https://github.com/userver-framework/userver/blob/develop/LICENSE)
and [CLA](https://github.com/userver-framework/userver/blob/develop/CONTRIBUTING.md). Services based on the template may change the license and CLA.

The service will continue the Apache-2.0 License.

---

## Setup the environment before building

```sh
# some library:
sudo apt update && sudo apt install libkrb5-dev libldap2-dev

# Install postgres libraries:
sudo apt install libpq-dev postgresql-server-dev-16
```

## Preparing environments for building

What to need to install in sytem first:

1. Install boost libraries:

    ```sh
        #Before installing Boost, check if it is already installed and its version:
        dpkg -l | grep libboost

        # check avalible version at repository:
        apt-cache policy libboost-dev

        # instal command:
        sudo apt install libboost-all-dev
    ```

2. Install protobuf:

    to erase all files in folder: `rm -rf *`

    Install Protobuf from source:
    
    ```sh
        # clone the repository:
        git clone --recursive https://github.com/protocolbuffers/protobuf.git /tmp/protobuf

        # checkout to defined version (887e95d is commit hash fo c++ version 27.1):
        cd /tmp/protobuf && git checkout 887e95d
        git submodule update --init --recursive

        mkdir cmake/build-debug && cd cmake/build-debug

        # run configuration:
        #cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Debug ../..
        #cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release ../..
        cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr/local ../..
        
        #cmake --build . 
        make -j$(nproc)
        sudo make install
        sudo ldconfig
        
        # install protobuf:
        sudo make install
        sudo ldconfig

    ```

    Install GRPC from source:

    ```sh
        git clone --recursive https://github.com/grpc/grpc.git /tmp/grpc
        cd /tmp/grpc

        # Checkout desired version (optional)
        # 4795c5e - is hash for commit grpc Release v.1.64.2
        git checkout 4795c5e  # Replace with the desired version
        git submodule update --init --recursive

        # Build gRPC
        mkdir cmake/build && cd cmake/build
        cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr/local ../..
        make -j$(nproc)
        sudo make install
        sudo ldconfig
    ```

3. Install OpenSSL, Cmake module for Jemalloc and others:

    ```sh
        sudo apt install libssl-dev libyaml-cpp-dev libzstd-dev libjemalloc-dev libnghttp2-dev libev-dev libzstd-dev #libgrpc-dev libgrpc++-dev protobuf-compiler-grpc
    ```

4. Install postresql:

    ```sh
        # Setup dependencies
        sudo apt install wget ca-certificates gnupg2 lsb-release

        # Create repository config file
        sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

        # Download signature key
        wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

        # Update packages list and install last PostgreSQL version
        sudo apt-get update && sudo apt-get -y install postgresql

        # Check the instalation:
        service postgresql status
    ```

---

## Run builded service

```sh
mkdir build_debug && cd build_debug

cmake -DCMAKE_BUILD_TYPE=Debug ..
# or 
cmake -DCMAKE_BUILD_TYPE=Release ..

cmake --build .

# By command in building directory or provide full path to binaries:
# Before running the service, see below how to setup db.
./u_tasks_repository -c ../configs/static_config.yaml

# or by make <command>

# Run benchmarks with command:
./u_tasks_repository_benchmark

# Run unittests with command:
./u_tasks_repository_unittest

```

---

## Work with db

### Setup db

Connect to db like super user `sudo -u postgres psql`.

Create user:

```sql
CREATE USER u_tasks_server WITH PASSWORD '1BEyhMioH{[71K;a';
```

Create db for the user:

```sql
   CREATE DATABASE u_tasks_repository_db_1 OWNER u_tasks_server;
```

Now you can try to connect to db throught terminal:

```sh
psql -p 5432 -U u_tasks_server -W -h localhost -d u_tasks_repository_db_1
```

Here parameters is:
`-p 5432` set a port.
`-U u_tasks_server` указывает имя пользователя.
`-h localhost` connect to local db.
`-W` means that command will ask for db's user password.

Other usable commands in Postgres CLI:

```sh
\conninfo #show connection info
\du # list users is known to DBMS and their roles
\l # list avalible DB's
exit # close the session
```

### Connect to db in the service 

Use connection link:
`postgresql://u_tasks_server:1BEyhMioH{[71K;a@localhost:5432/u_tasks_repository_db_1`

### Run with static handler

To run with static handler, you need define an evironment variable `USERVER_FILES_CONTENT_TYPE_MAP`:

```sh
export USERVER_FILES_CONTENT_TYPE_MAP=".html=text/html,.css=text/css,.js=application/javascript,.png=image/png,.jpg=image/jpeg,.jpeg=image/jpeg,.gif=image/gif,.svg=image/svg+xml"
```

To verify that the environment variable is set correctly run command:
`echo $USERVER_FILES_CONTENT_TYPE_MAP`

---

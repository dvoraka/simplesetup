# simplesetup

Simple setup script for Python environments. Copy script into your project directory and set variables. You need Bash to run.

Variables:

```
# SSH username
USER='user'
# SSH host address
HOST='localhost'
# project directory
PDIR='projectroot'
# virtual env. directory name
VIRT_ENV='test222'
# virtual environments directory
VE_DIR='virtenvs'
```
## Example
```
$ ./simplesetup.sh 
----
  1) create remote virtual env
  2) install remote hard dependencies
  3) create and install remote virtual env
  4) install remote dependencies
  5) sync remote files
  8) generate exclude file
  9) quit

Enter choice: 9

$
```

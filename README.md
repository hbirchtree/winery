Winery
======

A collection of scripts used to manage Wine prefixes and programs. Is quite extensible given its use of BASH.

IMPORTANT: This collection of scripts is provided without any sort of guarantee of working, and you are personally responsible for whatever happens by using them, even if you did not read this README beforehand.

What is Winery?
======

It is a collection of scripts that I have personally used to manage my Wine prefixes and their following programs in a relatively simple way. The reason why I wrote this in the first place is that I wasn't satisfied with the existing solutions out there. Some of them were hard to modify, covered in lots of code that isn't as manageable if you are an outsider to the project, or that just don't work. Winery is written with simplicity in mind, and thus does not have any GUI to speak of. It is made to not be in the way when you launch a game or program, while allowing a lot of options for the launch process, all behind the scenes, only showing itself when you want to configure a new game or when you need to fix something.

How is it written?
======
It is written entirely in BASH, and is supposed to be extendable and modifiable. For this reason I have separated it into several, smaller scripts, which I would call modules, that can be sourced into the main script as needed. I recommended looking over and modifying them to suit your needs, and also reading the descriptions found in each module, as some of them provide important or helpful information.

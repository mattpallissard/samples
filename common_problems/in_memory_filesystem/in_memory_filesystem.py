from enum import Enum, auto
class Content(Enum):
    STRING = auto()
    INT = auto()
    BYTES = auto()
    DIR = auto()

File = { 'contents': None}
Dir = File ** { 'type': Content.DIR}
Str = File ** { 'type': Content.STRING}

class FS():

    empty = {}

    def stat(i, j):
        if i in j:
            return True
        False

    def setp(path, contents, tree):
        tree[path] = contents
        return tree

    def get(path, tree):
        return tree[path]

    def write(path, contents, tree):
        if FS.stat(path, tree) is True:
            raise Exists_file
        def aux(tree, root, sp):
            nonlocal path
            if sp == []:
                return FS.setp(path, contents, tree)
            path = root + "/" + sp[0]
            if FS.stat(path, tree) is False:
                aux(tree, path, sp[1:])
            else:
                return aux(FS.setp(path, Dir , tree), path, sp[1:])
        return aux(tree, "", path.split("/")[1:])

    def mkdir(path, tree):
        return FS.write(path, Dir, tree)




print("/foo/bar/baz".split("/"))
foo = FS.mkdir("/foo/bar/baz", FS.empty)
data = Str
data['contents'] = "lolwut"
bar = FS.write("/foo/bar/baz", data, foo)
# never makes it here
print(bar)

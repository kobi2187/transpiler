# "Namespace: TestApp"
type
  Person = ref object
    name: string
    age: int

proc newPerson(n: string, a: int): Person =
  name = n
  age = a

## Modules
You can use different modules from "Base" for vehicle scripts but in some cases you will need to use the module + id within your files if you do that. 
examples where you need to use module + id.
when adding a template
```
template = module.template/part/Part,
```
when adding a model for part
```
model name { file = module.model, }
```

## Table Block

add a value, needs comma 
`x = y,` 
add table, doesn't need comma 
`myTable {...}` 
normally all values are of type string and often `;` is used for multiple values that are later split
make a sorted table, keys are converted to integers when possible 
`myTable { 1 = a, 2 = b, }` 
remove a value from table 
`x = ,` 

when you use getTable("mytable") you get a copy of the table
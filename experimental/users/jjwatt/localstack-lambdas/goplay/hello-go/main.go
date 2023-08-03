package main

import (
	"fmt"
	"runtime"
)

func main() {
	// assign a function to a name
	add := func(a, b int) int {
		return a + b
	}
	fmt.Println(add(3, 4)) // use the name to call the function
	fn_from_scope := scope()
	fmt.Println("call fn_from_scope(): ", fn_from_scope())
	inner, outer_var := outer()
	fmt.Println("inner call, outer_var: ", inner(), outer_var)

	nums := []int{10, 20, 30}
	fmt.Println("pass adder(...) nums array: ", adder(nums...))

	fmt.Println("OS: ", what_os())
	fmt.Println("GOROOT: ", runtime.GOROOT())
	fmt.Println("GOMAXPROCS: ", runtime.GOMAXPROCS(0))

	var awesomer Awesomer
	awesomer = new(Foo)
	fmt.Println("Call Awesomer: ", awesomer.Awesomeize())

	// printing structs and shit
	p := struct{ X, Y int }{17, 2}
	fmt.Println("My point:", p, "x coord=", p.X)

	// print to a string variable
	s := fmt.Sprintln("My point:", p, "x coord=", p.X)
	fmt.Println("s that I wrote to: ", s)
	// C style print to string
	s2 := fmt.Sprintf("%d %f", 17, 17.0)
	fmt.Println("s2 that I Sprintf'd to: ", s2)

	// multi-line string literal, using back-tick at beginning and end
	hellomsg := `
          "Hello" in Chinese is 你好 ('Ni Hao')
	  "Hello" in Hindi is नमते ('Namaste')
	`
	fmt.Println("hello multi-line string: ", hellomsg)

}

// Closures, lexically scoped: functions can access values that were in scope
// when defining the function
func scope() func() int {
	outer_var := 2
	foo := func() int { return outer_var }
	return foo
}

// Closures
func outer() (func() int, int) {
	outer_var := 2
	inner := func() int {
		outer_var += 99 // outer_var from outer scope is mutated
		return outer_var
	}
	inner()
	return inner, outer_var
}

func adder(args ...int) int {
	total := 0
	for _, v := range args {
		total += v
	}
	return total
}

func what_os() string {
	var msg string
	switch os := runtime.GOOS; os {
	case "darwin":
		msg = "macOS"
	case "linux":
		msg = "lucky"
	default:
		msg = "something else"
	}
	return msg
}

// Interfaces
// Awesomer is an interface with an Awesomeize Method
type Awesomer interface {
	Awesomeize() string
}

// types do not declare to implement interfaces
type Foo struct{}

// instead, types implicitly satisfy an interface
// if they implement all required methods
func (foo Foo) Awesomeize() string {
	return "Awesome!"
}

// Embedding
// No subclassing in Go. But, there is interface and struct embedding
// ReadWriter implementations must satisfy both Reader and Writer
// type ReadWriter interface {
// 	Reader
// 	Writer
// }
// Server exposes all the methods that Logger has
// type Server struct {
// 	Host string
// 	Port int
// 	*log.Logger
// }
// Initialize the embedded type the usual way:
//
// server := &Server{"localhost", 80, log.New(...)}
//
// methods implemented on the embedded struct are passed through
//
// server.Log(...) // calls server.Logger.Log(...)
//
// the field name of the embedded type is its type name (in this case, Logger)
// var logger *log.Logger = server.Logger

// Errors
// no exception handling
// functions that might produce an error just declare an additional return
// value of type Error
// This is the Error interface:
// type error interface {
// 	Error() string
// }
// func doStuff() (int, error) {}
// result, err := doStuff()
// if err != nil {} else {}

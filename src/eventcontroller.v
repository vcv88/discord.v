module discord

import time

pub type EventListener[T] = fn (T) !

@[heap]
struct InternalChan[T] {
	c chan T
}

pub type Check[T] = fn (T) bool

struct EventWaiter[T] {
	check ?Check[T]
	c     InternalChan[T]
}

/*
// Not sure about this
@[unsafe]
fn (mut ew EventWaiter[T]) free() {
	unsafe {
		ew.c.free()
	}
} */

pub struct EventController[T] {
mut:
	id        int
	wait_fors map[int]EventWaiter[T]
	listeners map[int]EventListener[T]
}

fn (mut ec EventController[T]) generate_id() int {
	return ec.id++
}

@[params]
pub struct EmitOptions {
pub:
	error_handler ?fn (int, IError)
}

// `emit` broadcasts passed object to all listeners
pub fn (mut ec EventController[T]) emit(e T, options EmitOptions) {
	for _, w in ec.wait_fors {
		mut b := false
		if w.check != none {
			c := w.check
			b = c(e)
		} else {
			b = true
		}
		if b {
			w.c.c <- e
			// ec.wait_fors.delete(i)
			return
		}
	}
	if ec.listeners.len == 0 {
		return
	}
	if ec.listeners.len == 1 {
		/* spawn fn [options] [T](f EventListener[T], e T) { //, options EmitOptions) {
			f(e) or {
				if g := options.error_handler {
					g(0, err)
				}
			}
		}(ec.listeners.values()[0], e) */

		f := (ec.listeners.values()[0])
		f(e) or {
			if g := options.error_handler {
				g(0, err)
			}
		}
		return
	}
	for i, l in ec.listeners {
		l(e) or {
			if g := options.error_handler {
				g(i, err)
			}
		}
	}
	/* mut ts := []thread{}
	for i, l in ec.listeners {
		ts << spawn fn [options] [T](f EventListener[T], j int, e T) {
			f(e) or {
				if g := options.error_handler {
					g(j, err)
				}
			}
		}(l, i, e)
	}
	ts.wait() */
}

@[params]
pub struct EventWaitParams[T] {
pub:
	check   ?Check[T]
	timeout ?time.Duration
}

pub struct EventChannel[T] {
	id      int
	timeout ?time.Duration
mut:
	controller &EventController[T]
}

// Closes an event channel
pub fn (mut a EventChannel[T]) close() {
	if a.controller == unsafe { nil } {
		return
	}
	a.controller.wait_fors.delete(a.id)
	a.controller = unsafe { nil }
}

// `receive` waits for event and returns it.
// After it returned event, you should call `close()` on it to release resources.
// If timeout is exceeded, it returns none
pub fn (mut a EventChannel[T]) receive() ?T {
	if a.controller == unsafe { nil } {
		return none
	}
	if w := a.controller.wait_fors[a.id] {
		// defer {
		// unsafe {
		//	w.free()
		//}
		// a.controller.wait_fors.delete(a.id)
		// }
		if timeout := a.timeout {
			select {
				r := <-w.c.c {
					return r
				}
				timeout.nanoseconds() {
					return none
				}
			}
		}
		return <-w.c.c
	}
	return none
}

// `wait` returns EventChannel that can be used to receive events
// > ! Do not use that directly in events, please take a reference using `mut controller := &events.creator.events.on_x`
pub fn (mut ec EventController[T]) wait(params EventWaitParams[T]) EventChannel[T] {
	id := ec.generate_id()
	ec.wait_fors[id] = EventWaiter[T]{
		check: params.check
		c: InternalChan[T]{}
	}
	return EventChannel[T]{
		id: id
		timeout: params.timeout
		controller: unsafe { &mut ec }
	}
}

// `override` removes all listeners and inserts `listener`
pub fn (mut ec EventController[T]) override(listener EventListener[T]) EventController[T] {
	ec.listeners = {
		ec.generate_id(): listener
	}
	return ec
}

// `listen` adds function to listener list
pub fn (mut ec EventController[T]) listen(listener EventListener[T]) EventController[T] {
	ec.listeners[ec.generate_id()] = listener
	return ec
}

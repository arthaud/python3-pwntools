<% from pwnlib.shellcraft import i386 %>
<% from pwnlib.util import misc %>
<%docstring>
Pushes an array/envp-style array of pointers onto the stack.

Arguments:
    reg(str):
        Destination register to hold the pointer.
    array(bytes, str, list):
        Single argument or list of arguments to push.
        NULL termination is normalized so that each argument
        ends with exactly one NULL byte.
</%docstring>
<%page args="reg, array"/>
<%
if isinstance(array, (bytes, str)):
    array = [array]

# Normalize all of the arguments' endings
array = list(map(misc.force_bytes, array))
array = [arg.rstrip(b'\x00') + b'\x00' for arg in array]
array_str  = b''.join(array)

word_size = 4
offset = len(array_str) + word_size

%>\
    /* push argument array ${repr(array)} */
    ${i386.pushstr(array_str)}
    ${i386.mov(reg, 0)}
    push ${reg} /* null terminate */
% for i, arg in enumerate(reversed(array)):
    ${i386.mov(reg, offset + word_size*i - len(arg))}
    add ${reg}, esp
    push ${reg} /* ${repr(arg)} */
    <% offset -= len(arg) %>\
% endfor
    ${i386.mov(reg, 'esp')}
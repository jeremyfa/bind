package bind;

/**
 * Java support file for bind.
 */
public class Support {

/// Function types

    public interface Func0<T> {

        T run();

    } //Func0

    public interface Func1<A1,T> {

        T run(A1 arg1);

    } //Func1

    public interface Func2<A1,A2,T> {

        T run(A1 arg1, A2 arg2);

    } //Func2

    public interface Func3<A1,A2,A3,A4,A5,A6,A7,A8,A9,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4, A5 arg5, A6 arg6, A7 arg7, A8 arg8, A9 arg9);

    } //Func3

    public interface Func4<A1,A2,A3,A4,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4);

    } //Func4

    public interface Func5<A1,A2,A3,A4,A5,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4, A5 arg5);

    } //Func5

    public interface Func6<A1,A2,A3,A4,A5,A6,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4, A5 arg5, A6 arg6);

    } //Func6

    public interface Func7<A1,A2,A3,A4,A5,A6,A7,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4, A5 arg5, A6 arg6, A7 arg7);

    } //Func7

    public interface Func8<A1,A2,A3,A4,A5,A6,A7,A8,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4, A5 arg5, A6 arg6, A7 arg7, A8 arg8);

    } //Func8

    public interface Func9<A1,A2,A3,A4,A5,A6,A7,A8,A9,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4, A5 arg5, A6 arg6, A7 arg7, A8 arg8, A9 arg9);

    } //Func9

/// Native init

    public static native void init();

} //Support

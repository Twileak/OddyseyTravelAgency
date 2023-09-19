public with sharing class CheckRecursive {
    private static Integer run = 0;
    public static Boolean runOnce() {
        if(run<2) {
            run=run+1;
            return true;
        } else {
            return false;
        }
    }
}
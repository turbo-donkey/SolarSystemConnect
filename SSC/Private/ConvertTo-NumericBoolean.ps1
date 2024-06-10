function ConvertTo-NumericBoolean($bool) {
    if ($bool) {
        return "1"
    } else {
        return "0"
    }
}
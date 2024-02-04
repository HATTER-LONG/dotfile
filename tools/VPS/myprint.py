from datetime import datetime


# 定义 ANSI 颜色转义码
class Color:
    RESET = "\033[0m"
    BOLD = "\033[1m"
    UNDERLINE = "\033[4m"
    # 文字颜色
    BLACK = "\033[30m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    WHITE = "\033[37m"

    # 背景颜色
    BG_BLACK = "\033[40m"
    BG_RED = "\033[41m"
    BG_GREEN = "\033[42m"
    BG_YELLOW = "\033[43m"
    BG_BLUE = "\033[44m"
    BG_MAGENTA = "\033[45m"
    BG_CYAN = "\033[46m"
    BG_WHITE = "\033[47m"


def print_colored_timestamp(message, color=Color.RESET):
    # 获取当前时间戳
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    # 打印带颜色和时间戳的文本
    print(f"[{timestamp}] {color}{message}{Color.RESET}")


def pError(message):
    print_colored_timestamp(message, color=Color.RED)


def pWarning(message):
    print_colored_timestamp(message, color=Color.YELLOW)


def pInfo(message):
    print_colored_timestamp(message, color=Color.BLUE)


def pSuccess(message):
    print_colored_timestamp(message, color=Color.GREEN)

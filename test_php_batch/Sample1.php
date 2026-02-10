<?php
declare(strict_types=1);

namespace App\Models;

use App\Contracts\Renderable;
use App\Traits\{HasTimestamps, SoftDeletes};
use App\Enums\Status;

// File-level constant
const APP_VERSION = '1.0.0';

/**
 * Base model class demonstrating PHP 8.4 features
 */
abstract class BaseModel
{
    // Class constants with typed constants (PHP 8.3)
    public const string TABLE_PREFIX = 'app_';

    // Properties
    private readonly string $id;
    protected string $name = '';
    public static int $instanceCount = 0;

    // Constructor with promoted properties (PHP 8.0)
    public function __construct(
        protected string $createdAt = '',
        private int $version = 1,
    ) {
        $this->id = uniqid();
        self::$instanceCount++;
    }

    public function __destruct()
    {
        self::$instanceCount--;
    }

    abstract public function getTableName(): string;

    public function getId(): string
    {
        return $this->id;
    }
}

/**
 * User model with modern PHP features
 */
class User extends BaseModel implements Renderable
{
    use HasTimestamps, SoftDeletes {
        HasTimestamps::touch as touchTimestamp;
        SoftDeletes::delete insteadof HasTimestamps;
    }

    // Property hooks (PHP 8.4)
    public string $displayName {
        get => $this->firstName . ' ' . $this->lastName;
        set {
            [$this->firstName, $this->lastName] = explode(' ', $value, 2);
        }
    }

    // Asymmetric visibility (PHP 8.4)
    public private(set) string $email;

    // Readonly property
    public readonly int $age;

    public function __construct(
        private string $firstName,
        private string $lastName,
        string $email,
        int $age,
        protected array $roles = ['user'],
    ) {
        parent::__construct();
        $this->email = $email;
        $this->age = $age;
    }

    public function getTableName(): string
    {
        return self::TABLE_PREFIX . 'users';
    }

    // Return type: union type (PHP 8.0)
    public function toArray(): array|false
    {
        return [
            'id' => $this->getId(),
            'name' => $this->displayName,
            'email' => $this->email,
            'age' => $this->age,
            'roles' => $this->roles,
        ];
    }

    // Intersection type (PHP 8.1)
    public function render(Renderable&\Stringable $component): string
    {
        return (string) $component;
    }

    // Nullable return type
    public function findRole(string $name): ?string
    {
        foreach ($this->roles as $role) {
            if ($role === $name) {
                return $role;
            }
        }
        return null;
    }

    // Static method
    public static function create(string ...$args): static
    {
        return new static(...$args);
    }

    // First-class callable (PHP 8.1)
    public function getRoleMapper(): \Closure
    {
        return strtoupper(...);
    }
}

// Interface
interface Cacheable
{
    public function getCacheKey(): string;
    public function getCacheTtl(): int;
}

// Trait
trait Loggable
{
    private array $logs = [];

    public function log(string $message, string $level = 'info'): void
    {
        $this->logs[] = [
            'message' => $message,
            'level' => $level,
            'timestamp' => time(),
        ];
    }

    public function getLogs(): array
    {
        return $this->logs;
    }
}

// Enum with backing type and methods (PHP 8.1)
enum Status: string
{
    case Active = 'active';
    case Inactive = 'inactive';
    case Pending = 'pending';
    case Suspended = 'suspended';

    public function label(): string
    {
        return match ($this) {
            self::Active => 'Active User',
            self::Inactive => 'Inactive User',
            self::Pending => 'Pending Approval',
            self::Suspended => 'Account Suspended',
        };
    }

    public function isActive(): bool
    {
        return $this === self::Active;
    }
}

// Pure enum (no backing type)
enum Direction
{
    case North;
    case South;
    case East;
    case West;
}

// Comprehensive expression examples
function demonstrateExpressions(): void
{
    // Variable declarations
    $x = 42;
    $y = 3.14;
    $name = "world";
    $isValid = true;
    $nothing = null;

    // Arithmetic
    $sum = $x + $y;
    $diff = $x - $y;
    $product = $x * $y;
    $quotient = $x / $y;
    $remainder = $x % 5;
    $power = $x ** 2;

    // String concatenation
    $greeting = "Hello, " . $name . "!";

    // Bitwise operations
    $bitwiseAnd = $x & 0xFF;
    $bitwiseOr = $x | 0x0F;
    $bitwiseXor = $x ^ 0x55;
    $bitwiseNot = ~$x;
    $shiftLeft = $x << 2;
    $shiftRight = $x >> 1;

    // Comparison
    $eq = $x == $y;
    $neq = $x != $y;
    $identical = $x === 42;
    $notIdentical = $x !== "42";
    $lt = $x < $y;
    $lte = $x <= $y;
    $gt = $x > $y;
    $gte = $x >= $y;
    $spaceship = $x <=> $y;

    // Logical
    $and = $isValid && $x > 0;
    $or = $isValid || $x < 0;
    $not = !$isValid;

    // Compound assignment
    $x += 10;
    $x -= 5;
    $x *= 2;
    $x /= 3;
    $x %= 7;
    $x **= 2;
    $x &= 0xFF;
    $x |= 0x01;
    $x ^= 0x55;
    $x <<= 1;
    $x >>= 2;
    $greeting .= " More";

    // Pre/post increment/decrement
    $x++;
    $x--;
    ++$x;
    --$x;

    // Ternary
    $result = $isValid ? "yes" : "no";

    // Elvis operator
    $val = $name ?: "default";

    // Null coalescing
    $safe = $nothing ?? "fallback";
    $nothing ??= "new value";

    // Match expression (PHP 8.0)
    $status = Status::Active;
    $label = match ($status) {
        Status::Active => 'Active',
        Status::Inactive, Status::Suspended => 'Disabled',
        default => 'Unknown',
    };

    // Array operations
    $arr = [1, 2, 3, 4, 5];
    $map = ['a' => 1, 'b' => 2, 'c' => 3];
    $nested = [[1, 2], [3, 4]];
    $first = $arr[0];
    $arr[] = 6;  // Append

    // Spread operator in arrays
    $merged = [...$arr, ...[7, 8, 9]];

    // List/destructuring
    [$a, $b, $c] = $arr;
    ['a' => $va, 'b' => $vb] = $map;

    // Type casting
    $intVal = (int) "42";
    $floatVal = (float) "3.14";
    $strVal = (string) 42;
    $boolVal = (bool) 1;
    $arrVal = (array) new \stdClass();
    $objVal = (object) ['name' => 'test'];

    // String interpolation
    $interpolated = "Hello $name, you are {$x} years old";

    // Heredoc
    $heredoc = <<<EOT
    This is a heredoc string
    with variable: $name
    EOT;

    // Nowdoc
    $nowdoc = <<<'EOT'
    This is a nowdoc string
    no variable interpolation
    EOT;

    // Instanceof
    $user = new User('John', 'Doe', 'john@example.com', 30);
    $isUser = $user instanceof User;

    // Clone
    $clone = clone $user;

    // Null-safe operator (PHP 8.0)
    $userName = $user?->displayName;
    $upper = $user?->displayName?->toUpperCase();

    // Named arguments (PHP 8.0)
    $result = array_slice($arr, offset: 1, length: 3);

    // First-class callable (PHP 8.1)
    $strlen = strlen(...);
    $mapped = array_map(strtoupper(...), ['a', 'b', 'c']);
}

// Control flow demonstration
function demonstrateControlFlow(mixed $value): string
{
    // If/elseif/else
    if ($value === null) {
        return "null";
    } elseif (is_int($value)) {
        return "integer: $value";
    } elseif (is_string($value)) {
        return "string: $value";
    } else {
        return "other";
    }
}

function demonstrateLoops(): void
{
    // While loop
    $i = 0;
    while ($i < 10) {
        echo $i;
        $i++;
    }

    // Do-while loop
    $j = 0;
    do {
        echo $j;
        $j++;
    } while ($j < 5);

    // For loop
    for ($k = 0; $k < 10; $k++) {
        if ($k === 5) {
            continue;
        }
        if ($k === 8) {
            break;
        }
        echo $k;
    }

    // Foreach with key
    $items = ['a' => 1, 'b' => 2, 'c' => 3];
    foreach ($items as $key => $value) {
        echo "$key: $value";
    }

    // Foreach without key
    foreach ([1, 2, 3] as $num) {
        echo $num;
    }
}

function demonstrateErrorHandling(): void
{
    // Try/catch/finally
    try {
        $result = riskyOperation();
    } catch (\InvalidArgumentException $e) {
        echo "Invalid argument: " . $e->getMessage();
    } catch (\RuntimeException | \LogicException $e) {
        echo "Runtime or logic error: " . $e->getMessage();
    } catch (\Throwable $e) {
        echo "Unexpected error: " . $e->getMessage();
    } finally {
        cleanup();
    }

    // Throw expression (PHP 8.0)
    $value = $input ?? throw new \InvalidArgumentException('Input required');

    // Error suppression
    $file = @fopen('nonexistent.txt', 'r');
}

// Closures and arrow functions
function demonstrateClosures(): void
{
    // Basic closure
    $greet = function (string $name): string {
        return "Hello, $name!";
    };

    // Closure with use
    $prefix = "Dear";
    $formalGreet = function (string $name) use ($prefix): string {
        return "$prefix $name";
    };

    // Arrow function (PHP 7.4+)
    $double = fn(int $x): int => $x * 2;

    // Arrow function with inherited scope
    $multiplier = 3;
    $multiply = fn($x) => $x * $multiplier;

    // Higher-order functions
    $numbers = [1, 2, 3, 4, 5];
    $evens = array_filter($numbers, fn($n) => $n % 2 === 0);
    $doubled = array_map(fn($n) => $n * 2, $numbers);
    $sum = array_reduce($numbers, fn($carry, $n) => $carry + $n, 0);
}

// Generator function
function fibonacci(): \Generator
{
    $a = 0;
    $b = 1;
    while (true) {
        yield $a;
        [$a, $b] = [$b, $a + $b];
    }
}

// Generator with key => value
function indexedItems(array $items): \Generator
{
    foreach ($items as $index => $item) {
        yield $index => strtoupper($item);
    }
}

// Generator delegation
function delegatingGenerator(): \Generator
{
    yield from [1, 2, 3];
    yield from fibonacci();
}

// Enum with interface implementation
enum Color: int implements Cacheable
{
    case Red = 0xFF0000;
    case Green = 0x00FF00;
    case Blue = 0x0000FF;

    public function getCacheKey(): string
    {
        return 'color_' . $this->name;
    }

    public function getCacheTtl(): int
    {
        return 3600;
    }

    public function toHex(): string
    {
        return '#' . str_pad(dechex($this->value), 6, '0', STR_PAD_LEFT);
    }
}

// Abstract class
abstract class Shape
{
    abstract public function area(): float;
    abstract public function perimeter(): float;

    public function describe(): string
    {
        return sprintf(
            "%s: area=%.2f, perimeter=%.2f",
            static::class,
            $this->area(),
            $this->perimeter()
        );
    }
}

// Final class
final class Circle extends Shape
{
    public function __construct(
        private readonly float $radius
    ) {}

    public function area(): float
    {
        return M_PI * $this->radius ** 2;
    }

    public function perimeter(): float
    {
        return 2 * M_PI * $this->radius;
    }
}

// Switch statement with fallthrough
function demonstrateSwitch(int $day): string
{
    switch ($day) {
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
            return "Weekday";
        case 6:
        case 7:
            return "Weekend";
        default:
            return "Invalid";
    }
}

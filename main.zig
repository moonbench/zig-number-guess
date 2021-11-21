const random = @import("std").rand.DefaultPrng;
const os = @import("std").os;
const mem = @import("std").mem;
const heap = @import("std").heap;
const fmt = @import("std").fmt;

const in = @import("std").io.getStdIn().reader();
const out = @import("std").io.getStdOut().writer();

const debug_mode = false;

// Set the range
const min: u8 = 0;
const max: u8 = 100;

pub fn main() !void {
    const answer = try pick_answer(min, max);
    try play_game(answer);
}

fn play_game(answer: u8) !void {
    var guesses: u8 = 1;
    while(true) : (guesses += 1){
        const guess = try get_guess();

        // Copmpare and decide winner
        if(guess < answer) try out.writeAll("Sorry, too small\n");
        if(guess > answer) try out.writeAll("Sorry, Too big\n");
        if(guess == answer) {
            try out.print("Yeah, that's it!\nGuesses taken: {}\n", .{guesses});

            return;
        }
    }
}

fn pick_answer(range_min: u8, range_max: u8) !u8 {
    try out.print("Picking a number between {} and {}...\n", .{min, max});

    // Create PRNG with an OS-provided random seed
    var seed: u64 = undefined;
    try os.getrandom(mem.asBytes(&seed));
    var prng = random.init(seed);

    // Select a number in the range of min to max
    const chosen = prng.random().intRangeLessThan(u8, range_min, range_max);

    if (debug_mode) try out.print("Debug: Chosen number was {}\n", .{chosen});

    return chosen;
}

fn get_guess() !u8 {
    while(true) {
        try out.writeAll("What's your guess? ");

        const raw_line = try in.readUntilDelimiterAlloc(
            heap.page_allocator,
            '\n',
            8192
        );
        defer heap.page_allocator.free(raw_line);
        const line = mem.trim(u8, raw_line, "\r");

        const guess = fmt.parseInt(u8, line, 10) catch |err| switch (err) {
            error.Overflow => {
                try out.writeAll("Enter a smaller guess\n");
                continue;
            },
            error.InvalidCharacter => {
                try out.writeAll("Enter an integer\n");
                continue;
            }
        };

        return guess;
    }
}

--!strict
--!native
--!optimize 2
const model: any = require("./Model");
const process: any = require("@lute/process") :: any;
const read_stdin = function(): string
	const args: {[number]: string} = process.args;
	const argv: number = #args;
	--print(argv);
	if (argv < 2) then
		return nil :: never;
	end;
	const out = table.concat(args, " ", 2) :: any;
	return out;
end;
const prompt: string? = read_stdin();
if (not prompt) then
	return error("You need a prompt dummy", 2);
end;
const model_response: string = model.prompt(prompt :: string);
print(model_response);

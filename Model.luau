--!nonstrict
--!native
--!optimize 2
--!nolint RedundantNativeAttribute
type fs = {open: (string, string) -> any, read: (any) -> string, write: (any, string) -> (), close: (any) -> (), exists: (string) -> boolean};
const fs: fs = require("@lute/fs") :: any;
const memory: typeof(buffer) = buffer;
const memcpy: (buffer, number, buffer, number?, number?) -> () = memory.copy;
const memset: (buffer, number, number, number?) -> () = memory.fill;
const calloc: (number) -> buffer = memory.create;
const malloc: (number, any) -> any = table.create;
const matrix_vector_mul = @[native, checked] function(operand_buffer: buffer, y0: number, w: buffer, w0: number, x: buffer, x0: number, n: number, k: number): ()
	const rs: number = k * 4;
	for i: number = 0, n - 1, 8 do
		const wo: number = w0 + i * rs - x0;
		local c0: number, c1: number, c2: number, c3: number, c4: number, c5: number, c6: number, c7: number = 0, 0, 0, 0, 0, 0, 0, 0;
		for i: number = x0, x0 + rs - 4, 4 do
			const v: number = memory.readf32(x, i);
			const o0: number = wo + i;
			c0 += memory.readf32(w, o0) * v;
			const o1: number = o0 + rs;
			c1 += memory.readf32(w, o1) * v;
			const o2: number = o1 + rs;
			c2 += memory.readf32(w, o2) * v;
			const o3: number = o2 + rs;
			c3 += memory.readf32(w, o3) * v;
			const o4: number = o3 + rs;
			c4 += memory.readf32(w, o4) * v;
			const o5: number = o4 + rs;
			c5 += memory.readf32(w, o5) * v;
			const o6: number = o5 + rs;
			c6 += memory.readf32(w, o6) * v;
			const o7: number = o6 + rs;
			c7 += memory.readf32(w, o7) * v;
		end;
		const final_f32: number = y0 + i * 4;
		memory.writef32(operand_buffer, final_f32, memory.readf32(operand_buffer, final_f32) + c0);
		memory.writef32(operand_buffer, final_f32 + 4, memory.readf32(operand_buffer, final_f32 + 4) + c1);
		memory.writef32(operand_buffer, final_f32 + 8, memory.readf32(operand_buffer, final_f32 + 8) + c2);
		memory.writef32(operand_buffer, final_f32 + 12, memory.readf32(operand_buffer, final_f32 + 12) + c3);
		memory.writef32(operand_buffer, final_f32 + 16, memory.readf32(operand_buffer, final_f32 + 16) + c4);
		memory.writef32(operand_buffer, final_f32 + 20, memory.readf32(operand_buffer, final_f32 + 20) + c5);
		memory.writef32(operand_buffer, final_f32 + 24, memory.readf32(operand_buffer, final_f32 + 24) + c6);
		memory.writef32(operand_buffer, final_f32 + 28, memory.readf32(operand_buffer, final_f32 + 28) + c7);
	end;
	return;
end;
const main = @[native, checked] function(data_buffer: buffer, prompt: string, count: number): string
	local handle: any = fs.open("data/tokenizer.bin", "r");
	const tokenizer: buffer = memory.fromstring(fs.read(handle));
	fs.close(handle);
	const r: buffer = calloc(2097152);
	memset(r, 0, 0xFF);
	const token_text: {[number]: string} = malloc(1024);
	for i: number = 0, 255 do
		token_text[i + 1] = string.char(i);
	end;
	for i: number = 256, 1023 do
		const pair_uint32: number = memory.readu32(tokenizer, (i - 256) * 4);
		memory.writeu16(r, bit32.replace(bit32.rshift(pair_uint32, 15), pair_uint32, 11, 10), i);
		token_text[i + 1] = `{token_text[bit32.band(pair_uint32, 0xFFFF) + 1]}{token_text[bit32.rshift(pair_uint32, 16) + 1]}`;
	end;
	const text: string = `\n{prompt:gsub("[^\n\32-\126]", ""):gsub(" +", " "):gsub(" ?\n ?", "\n"):gsub("^ ", ""):gsub(" $", "")}`;
	const n: number = #text;
	const src: buffer = memory.create(n + 1);
	memory.writestring(src, 0, text);
	const classes_buffer: buffer = calloc(n + 1);
	memory.writestring(classes_buffer, 0, (text:gsub("%a", "\1"):gsub("%d", "\2"):gsub(" ", "\4"):gsub("[^\1\2\4]", "\3")));
	const tmp_buffer: buffer = calloc(n * 2);
	const history: {[number]: number} = {};
	local i: number = 0;
	while (i < n) do
		local e: number = i;
		local cls_uint8: number = memory.readu8(classes_buffer, e);
		if (cls_uint8 == 4) then
			e += 1;
			cls_uint8 = memory.readu8(classes_buffer, e);
		elseif (cls_uint8 < 3) then
			repeat
				e += 1;
			until (memory.readu8(classes_buffer, e) ~= cls_uint8);
		else
			e += 1;
		end;
		local len_uint32: number = e - i;
		for k: number = 0, len_uint32 - 1 do
			memory.writeu16(tmp_buffer, k * 2, memory.readu8(src, i + k));
		end;
		while (true) do
			local _z: number, _k: number = 0xFFFF, 0;
			for k: number = 0, len_uint32 * 2 - 4, 2 do
				const pair_uint32: number = memory.readu32(tmp_buffer, k);
				const z: number = memory.readu16(r, bit32.replace(bit32.rshift(pair_uint32, 15), pair_uint32, 11, 10));
				if (z < _z) then
					_z = z;
					_k = k;
				end;
			end;
			if (_z == 0xFFFF) then
				--print("why is this happening", _z, pair_uint32);
				break;
			end;
			memory.writeu16(tmp_buffer, _k, _z);
			memcpy(tmp_buffer, _k + 2, tmp_buffer, _k + 4, len_uint32 * 2 - _k - 4);
			len_uint32 -= 1;
		end;
		for i: number = 0, len_uint32 * 2 - 2, 2 do
			table.insert(history, memory.readu16(tmp_buffer, i));
		end;
		i = e;
	end;
	const s: buffer = calloc(7424);
	const kv: buffer = calloc(294912);
	const out: {[number]: string} = malloc(count);
	local next_k: number = math.max(1, #history - 127);
	local pos: number = 0;
	while (true) do
		if (pos == 128) then
			pos = 0;
			next_k = #history - 31;
		end;
		const eo: number = history[next_k] * 256;
		const po: number = 262144 + pos * 256;
		for i: number = 0, 252, 4 do
			memory.writef32(s, i, memory.readf32(data_buffer, eo + i) + memory.readf32(data_buffer, po + i));
		end;
		const itter_size_uint8: number = next_k == #history and 6 or 5;
		for i: number = 0, itter_size_uint8 do
			const g: number = 884736 + i * 256;
			local sm: number, ss: number = 0, 0;
			for i: number = 0, 252, 4 do
				const v: number = memory.readf32(s, i);
				sm += v;
				ss += v * v;
			end;
			const m: number = sm / 64;
			const rstd: number = 1 / math.sqrt(ss / 64 - m * m + 1e-5);
			for i: number = 0, 252, 4 do
				memory.writef32(s, 256 + i, (memory.readf32(s, i) - m) * rstd * memory.readf32(data_buffer, g + i));
			end;
			const l: number = bit32.rshift(i, 1);
			const pl: number = 294912 + l * 196608;
			if (i == 6) then
				memset(s, 3328, 0, 4096);
				matrix_vector_mul(s, 3328, data_buffer, 0, s, 256, 1024, 64);
			elseif (bit32.band(i, 1) == 0) then
				const kl_uint32: number = l * 98304;
				const row_uint32: number = kl_uint32 + pos * 768;
				memset(kv, row_uint32, 0, 768);
				matrix_vector_mul(kv, row_uint32, data_buffer, pl, s, 256, 192, 64);
				for i: number = 0, 3 do
					const qo: number = row_uint32 + i * 64;
					const ko: number = kl_uint32 + 256 + i * 64;
					const q0: number, q1: number, q2: number, q3: number = memory.readf32(kv, qo) * 0.25, memory.readf32(kv, qo + 4) * 0.25, memory.readf32(kv, qo + 8) * 0.25, memory.readf32(kv, qo + 12) * 0.25;
					const q4: number, q5: number, q6: number, q7: number = memory.readf32(kv, qo + 16) * 0.25, memory.readf32(kv, qo + 20) * 0.25, memory.readf32(kv, qo + 24) * 0.25, memory.readf32(kv, qo + 28) * 0.25;
					const q8: number, q9: number, q10: number, q11: number = memory.readf32(kv, qo + 32) * 0.25, memory.readf32(kv, qo + 36) * 0.25, memory.readf32(kv, qo + 40) * 0.25, memory.readf32(kv, qo + 44) * 0.25;
					const q12: number, q13: number, q14: number, q15: number = memory.readf32(kv, qo + 48) * 0.25, memory.readf32(kv, qo + 52) * 0.25, memory.readf32(kv, qo + 56) * 0.25, memory.readf32(kv, qo + 60) * 0.25;
					local meow: number = -1e9;
					for i: number = 0, pos do
						const kj: number = ko + i * 768;
						const d: number = q0 * memory.readf32(kv, kj) + q1 * memory.readf32(kv, kj + 4) + q2 * memory.readf32(kv, kj + 8) + q3 * memory.readf32(kv, kj + 12) + q4 * memory.readf32(kv, kj + 16) + q5 * memory.readf32(kv, kj + 20) + q6 * memory.readf32(kv, kj + 24) + q7 * memory.readf32(kv, kj + 28) + q8 * memory.readf32(kv, kj + 32) + q9 * memory.readf32(kv, kj + 36) + q10 * memory.readf32(kv, kj + 40) + q11 * memory.readf32(kv, kj + 44) + q12 * memory.readf32(kv, kj + 48) + q13 * memory.readf32(kv, kj + 52) + q14 * memory.readf32(kv, kj + 56) + q15 * memory.readf32(kv, kj + 60);
						memory.writef32(s, 2816 + i * 4, d);
						meow = math.max(meow, d);
					end;
					local sum: number = 0;
					local a0: number, a1: number, a2: number, a3: number, a4: number, a5: number, a6: number, a7: number = 0, 0, 0, 0, 0, 0, 0, 0;
					local a8: number, a9: number, a10: number, a11: number, a12: number, a13: number, a14: number, a15: number = 0, 0, 0, 0, 0, 0, 0, 0;
					for i: number = 0, pos do
						const e: number = math.exp(memory.readf32(s, 2816 + i * 4) - meow);
						const f: number = ko + 256 + i * 768;
						sum += e;
						a0 += e * memory.readf32(kv, f);
						a1 += e * memory.readf32(kv, f + 4);
						a2 += e * memory.readf32(kv, f + 8);
						a3 += e * memory.readf32(kv, f + 12);
						a4 += e * memory.readf32(kv, f + 16);
						a5 += e * memory.readf32(kv, f + 20);
						a6 += e * memory.readf32(kv, f + 24);
						a7 += e * memory.readf32(kv, f + 28);
						a8 += e * memory.readf32(kv, f + 32);
						a9 += e * memory.readf32(kv, f + 36);
						a10 += e * memory.readf32(kv, f + 40);
						a11 += e * memory.readf32(kv, f + 44);
						a12 += e * memory.readf32(kv, f + 48);
						a13 += e * memory.readf32(kv, f + 52);
						a14 += e * memory.readf32(kv, f + 56);
						a15 += e * memory.readf32(kv, f + 60);
					end;
					const a: number = 1 / sum;
					const b: number = 512 + i * 64;
					memory.writef32(s, b, a0 * a);
					memory.writef32(s, b + 4, a1 * a);
					memory.writef32(s, b + 8, a2 * a);
					memory.writef32(s, b + 12, a3 * a);
					memory.writef32(s, b + 16, a4 * a);
					memory.writef32(s, b + 20, a5 * a);
					memory.writef32(s, b + 24, a6 * a);
					memory.writef32(s, b + 28, a7 * a);
					memory.writef32(s, b + 32, a8 * a);
					memory.writef32(s, b + 36, a9 * a);
					memory.writef32(s, b + 40, a10 * a);
					memory.writef32(s, b + 44, a11 * a);
					memory.writef32(s, b + 48, a12 * a);
					memory.writef32(s, b + 52, a13 * a);
					memory.writef32(s, b + 56, a14 * a);
					memory.writef32(s, b + 60, a15 * a);
				end;
				matrix_vector_mul(s, 0, data_buffer, pl + 49152, s, 512, 64, 64);
			else
				memset(s, 768, 0, 1024);
				matrix_vector_mul(s, 768, data_buffer, pl + 65536, s, 256, 256, 64);
				for i: number = 768, 1788, 4 do
					const x: number = memory.readf32(s, i);
					memory.writef32(s, i + 1024, 0.5 * x * (1 + math.tanh(0.79788456080286541 * (x + 0.044715 * x * x * x))));
				end;
				matrix_vector_mul(s, 0, data_buffer, pl + 131072, s, 1792, 64, 256);
			end;
		end;
		pos += 1;
		next_k += 1;
		if (next_k > #history) then
			if (#out == 0) then 
				for i: number = 0, 1023 do -- BUFFER ACCESS OUT OF BOUNDS.
					if (string.byte(token_text[i + 1]) ~= 32) then
						memory.writef32(s, 3328 + i * 4, -1e9);
					end;
				end;
			end;
			const tbl: {[number]: number} = table.create(1024);
			for i: number = 0, 1023 do
				tbl[i + 1] = memory.readf32(s, 3328 + i * 4);
			end;
			table.sort(tbl);
			const cut: number = tbl[985];
			const mx: number = tbl[1024];
			--print(mx);
			local sum: number = 0;
			for i: number = 3328, 7420, 4 do
				const logit: number = memory.readf32(s, i);
				const operand: number = logit >= cut and math.exp((logit - mx) / 0.8) or 0;
				memory.writef32(s, i, operand);
				sum += memory.readf32(s, i);
			end;
			const r: number = math.random() * sum;
			local acc: number = 0;
			local id: number = -1;
			repeat
				id += 1;
				acc += memory.readf32(s, 3328 + id * 4);
			until (acc > r);
			table.insert(history, id);
			table.insert(out, token_text[id + 1]);
			if (#out == count) then
				--print("done gen");
				break;
			end;
		end;
	end;
	return `{string.sub(text, 2)}{table.concat(out)}`;
end;
const prompt = @[native, checked] function(prompt: string): string
	local handle: any = fs.open("data/model.bin", "r");
	const data_buffer: buffer = memory.fromstring(fs.read(handle));
	fs.close(handle);
	return main(data_buffer, prompt, 200);
end;
return {prompt = prompt};

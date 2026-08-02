import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  reactStrictMode: true,
  output: 'standalone',
  // TypeScript 7 is a native compiler; Next needs the CLI typecheck path.
  experimental: {
    useTypeScriptCli: true,
  },
};

export default nextConfig;
